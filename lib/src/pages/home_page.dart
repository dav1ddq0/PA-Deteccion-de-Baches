import 'dart:async';
import 'package:deteccion_de_baches/src/utils/scaler.dart';
import 'package:deteccion_de_baches/src/utils/tools.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';

import 'package:deteccion_de_baches/src/utils/permissions.dart';
import 'package:deteccion_de_baches/src/utils/accelerometer_data.dart';
import 'package:deteccion_de_baches/src/utils/gyroscope_data.dart';
import 'package:deteccion_de_baches/src/utils/gps_data.dart';
import 'package:deteccion_de_baches/src/utils/signal_processing.dart';
import 'package:deteccion_de_baches/src/providers/menu_provider.dart';
import 'package:deteccion_de_baches/src/utils/icon_string.dart';
import 'package:deteccion_de_baches/src/utils/saved_data.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final String mainDirectory =
      '/storage/emulated/0/Baches'; // path where json data is stored
  final List<String> subdirectories = [
    'sensors',
    'mark_labels',
    'exported'
  ]; // path where sensor data is stored
  late TextEditingController fileNameController;
  String filename = '';

  int accelReadIntervals = 100;
  int geoLocReadIntervals = 1000;
  static const int speedReadIntervals = 5000;

  final streamSubscriptions = <StreamSubscription<dynamic>>[];

  final List<Map<String, dynamic>> sensorData = [];
  final List<Position?> geoLoc = [];
  final List<double> speedRead = [];

  late Position? prevGeoLocSpeedComp;

  late Timer accelTimer;
  late Timer speedTimer;
  late Timer geoLocTimer;

  late GyroscopeEvent gyroEvent;
  late UserAccelerometerEvent accelEvent;
  JData collectedData = JData();

  bool scanning = false; // Para saber si la app está escaneando o no
  bool bumpDetected = false;

  @override
  void initState() {
    fileNameController = TextEditingController();
    super.initState();
  }

  Position? get currentPosition {
    return geoLoc.isNotEmpty ? geoLoc.last : null;
  }
  // Métodos auxiliares

  List<double> updateGeoData(double currLat, currLong, prevLat, prevLong) {
    if (geoLoc.length == 1000) {
      geoLoc.removeAt(0);
    }

    return biAxialLowpassFilter(prevLat, prevLong, currLat, currLong);
  }

  /* GyroscopeData updateGyroData( */
  /*     double currReadX, */
  /*     double currReadY, */
  /*     double currReadZ, */
  /*     double prevReadX, */
  /*     double prevReadY, */
  /*     double prevReadZ) { */
  /*   if (gyroRead.length == 1000) { */
  /*     gyroRead.removeAt(0); */
  /*   } */

  /* List<double> filteredData = triAxialHighpassFilter( */
  /*       prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ); */

  /*   return GyroscopeData(x: filteredData[0], y: filteredData[1], z: filteredData[2]); */
  /* } */

  /* AccelerometerData updateAccelData( */
  /*     double currReadX, */
  /*     double currReadY, */
  /*     double currReadZ, */
  /*     double prevReadX, */
  /*     double prevReadY, */
  /*     double prevReadZ) { */
  /*   if (accelRead.length == 1000) { */
  /*     accelRead.removeAt(0); */
  /*   } */

  /* List<double> filteredData = triAxialHighpassFilter( */
  /*       prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ); */

  /*   return AccelerometerData(x: filteredData[0], y: filteredData[1], z: filteredData[2]); */
  /* } */

  Future<void> updateSpeedRead() async {
    if (speedRead.length == 1000) {
      speedRead.removeAt(0);
    }

    final double currSpeed = computeSpeed(
        prevGeoLocSpeedComp!.latitude,
        prevGeoLocSpeedComp!.longitude,
        geoLoc.last!.latitude,
        geoLoc.last!.longitude,
        (speedReadIntervals / 1000));

    if (currSpeed != 0) {
      double newSamplingRate = recomputeSamplingRate(1, currSpeed);
      accelReadIntervals = (1000 * newSamplingRate).floor();
      geoLocReadIntervals = (1000 * newSamplingRate).floor();
    }

    setState(() {
      if (geoLoc.isNotEmpty) {
        prevGeoLocSpeedComp = geoLoc.last;
      }
      speedRead.add(currSpeed);
    });
  }

  void subscribeAccelEventListener() {
    streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        accelEvent = event;
      });
    }));
  }

  void subscribeGyroEventListener() {
    streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroEvent = event;
      });
    }));
  }

  // Métodos activados por onPressed

  void labelAnomaly() {
    if (currentPosition != null) {
      collectedData.saveToJson2(
          '$mainDirectory/${subdirectories[1]}', currentPosition!);
    }
  }

  void switchTimerAndEvents() {
    if (scanning) {
      accelTimer =
          Timer.periodic(Duration(milliseconds: accelReadIntervals), (timer) {
        storeSensorData();
      });
      geoLocTimer =
          Timer.periodic(Duration(milliseconds: geoLocReadIntervals), (timer) {
        storeGeoData();
      });

      speedTimer = Timer.periodic(
          const Duration(milliseconds: speedReadIntervals), (timer) {
        updateSpeedRead();
      });

      if (streamSubscriptions.isEmpty) {
        subscribeAccelEventListener();
        subscribeGyroEventListener();
      } else {
        for (var subscription in streamSubscriptions) {
          subscription.resume();
        }
      }
    } else {
      geoLocTimer.cancel();
      accelTimer.cancel();
      for (var subscription in streamSubscriptions) {
        subscription.pause();
      }
    }
  }

  void switchScanning() {
    setState(() {
      scanning = !scanning;
    });

    setState(() {
      if (sensorData.isNotEmpty && !scanning) {
        collectedData.saveToJson(
            '$mainDirectory/${subdirectories[0]}', sensorData);
      }
    });

    switchTimerAndEvents();
  }

  Future<void> storeGeoData() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position newRead = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // double currLat = double.parse(newRead.latitude.toStringAsPrecision(10));
    // double currLong = double.parse(newRead.longitude.toStringAsPrecision(10));

    final double prevLat = geoLoc.isEmpty ? 0 : geoLoc.last!.latitude;
    final double prevLong = geoLoc.isEmpty ? 0 : geoLoc.last!.longitude;

    var newGeoFilt = [newRead.latitude, newRead.longitude];

    if (prevLat != 0 && prevLong != 0) {
      newGeoFilt =
          updateGeoData(newRead.latitude, newRead.longitude, prevLat, prevLong);
    }
    // Actualizar lecturas de velocidad y coordenadas.

    /* final readFiltered = Position( */
    /*   latitude: newGeoFilt.item1, */
    /*   longitude: newGeoFilt.item2, */
    /*   timestamp: newRead.timestamp, */
    /*   accuracy: newRead.accuracy, */
    /*   altitude: newRead.altitude, */
    /*   heading: newRead.heading, */
    /*   speed: newRead.speed, */
    /*   speedAccuracy: newRead.speedAccuracy, */
    /* ); */

    setState(() {
      geoLoc.add(newRead);
    });
  }

  Future<void> storeSensorData() async {
    /* final newAccelFilt = updateAccelData( */
    /*     currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ); */
    final double accelReadX = double.parse(accelEvent.x.toStringAsPrecision(6));
    final double accelReadY = double.parse(accelEvent.x.toStringAsPrecision(6));
    final double accelReadZ = double.parse(accelEvent.x.toStringAsPrecision(6));

    final AccelerometerData accelData =
        AccelerometerData(x: accelReadX, y: accelReadY, z: accelReadZ);

    final double gyroReadX = double.parse(accelEvent.x.toStringAsPrecision(6));
    final double gyroReadY = double.parse(accelEvent.x.toStringAsPrecision(6));
    final double gyroReadZ = double.parse(accelEvent.x.toStringAsPrecision(6));

    final GyroscopeData gyroData =
        GyroscopeData(x: gyroReadX, y: gyroReadY, z: gyroReadZ);

    setState(() {
      if (currentPosition != null) {
        sensorData.add({
          'accelerometer': accelData.values,
          'gyroscope': gyroData.values,
          'gps': {
            'latitude': currentPosition!.latitude,
            'longitude': currentPosition!.longitude
          }
        });

        /* accelRead */
        /*     .add(AccelerometerData(x: currReadX, y: currReadY, z: currReadZ)); */
        /* if (prevReadX != 0) { */
        /*   bumpDetected = scanPotholes( */
        /*       prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ); */
        /*   if (bumpDetected) { */
        /*     HapticFeedback.vibrate(); */
        /*   } */
        /* } */
      }
    });
  }

  /* Future<void> updateFilterGyroData() async { */
  /*   final double currReadX = double.parse(gyroEvent.x.toStringAsPrecision(6)); */
  /*   final double currReadY = double.parse(gyroEvent.y.toStringAsPrecision(6)); */
  /*   final double currReadZ = double.parse(gyroEvent.z.toStringAsPrecision(6)); */

  /*   final double prevReadX = gyroRead.isEmpty ? 0 : gyroRead.last.x; */
  /*   final double prevReadY = gyroRead.isEmpty ? 0 : gyroRead.last.y; */
  /*   final double prevReadZ = gyroRead.isEmpty ? 0 : gyroRead.last.z; */

  /*   /1* final newGyroFilt = updateGyroData( *1/ */
  /*   /1*     currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ); *1/ */

  /*   setState(() { */
  /*     gyroRead.add(GyroscopeData(x: currReadX, y: currReadY, z: currReadZ)); */
  /*   }); */
  /* } */

  // Método para construir el Widget

  @override
  Widget build(BuildContext context) {
    makeAppFolders(mainDirectory, subdirectories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bump Record'),
      ),
      body: createHomePageItems(),
    );
  }

  Widget createHomePageItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder(
            future: menu_provider.loadData(),
            initialData: [],
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              return ListView(
                  shrinkWrap: true,
                  children: createPagesAccessItems(snapshot.data, context));
            }),
        const SizedBox(
          height: 20,
        ),
        createAxisInfoItems(context)
      ],
    );
  }

  List<Widget> createPagesAccessItems(
      List<dynamic>? data, BuildContext context) {
    List<Widget> pagesItems = [];
    SizeConfig tilesSizeConfig = SizeConfig(context);

    if (data != null) {
      for (var elem in data) {
        final tempWidget = Container(
            height: tilesSizeConfig.screenHeight * 0.05,
            child: ListTile(
              title: Text(elem['text']),
              leading: getIcon(elem['icon']),
              trailing: const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Colors.amber,
              ),
              onTap: () {
                // final route = MaterialPageRoute(
                //   builder: (context) => InfoPage()
                // );
                // Navigator.push(context, route);

                Navigator.pushNamed(context, '/' + elem['route']);
              },
            ));

        pagesItems
          ..add(tempWidget)
          ..add(const Divider());
      }
    }
    return pagesItems;
  }

  Widget createAxisInfoItems(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 20,
          ),
          child: scanning
              ? const Text(
                  'Scannnig for bumps...Press again if you wish to stop scanning',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))
              : const Text('Press here to start scanning for bumps',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
          onPressed: switchScanning),
      const SizedBox(
        height: 10,
      ),
      Column(
        children: [
          const ListTile(
            leading: Icon(Icons.speed),
            title: Text(
              'curr speed',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Text(
            speedRead.isEmpty ? 'None' : '${speedRead.last} km/h',
            style: TextStyle(
                fontSize: 40,
                color: speedRead.isEmpty ? Colors.blueAccent : Colors.amber),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(
          children: [
            const Text(
              'Latitude',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              geoLoc.isNotEmpty ? '${geoLoc.last?.latitude}' : 'None',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Longitude',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              geoLoc.isNotEmpty ? '${geoLoc.last?.longitude}' : 'None',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
      ]),
      const SizedBox(
        height: 20,
      ),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 20,
          ),
          child: const Text('Label anomaly',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          onPressed: labelAnomaly),
      ElevatedButton(
        child: const Text('Save data as'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Name your data'),
                content: TextField(
                  controller: fileNameController,
                  decoration: const InputDecoration(
                      hintText: "Choose a name for this file"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('SAVE'),
                    onPressed: () {
                      filename = fileNameController.text;
                      collectedData.saveToJson(
                          '$mainDirectory/${subdirectories[2]}', sensorData,
                          filename: filename);

                      sensorData.clear();
                      collectedData
                          .deleteFile('$mainDirectory/${subdirectories[0]}');
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      )
      //   const Text(
      //     'Bump Detected',
      //     style: TextStyle(fontSize: 24),
      //   ),
      //   Text(
      //     bumpDetected ? 'Yes' : 'No',
      //     style: TextStyle(
      //         fontSize: 40,
      //         color: bumpDetected
      //             ? Colors.redAccent.shade700
      //             : Colors.greenAccent.shade700),
      //   ),
    ]);
  }
}
