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

  int accelReadIntervals = 1000;
  int geoLocReadIntervals = 1000;
  static const int speedReadIntervals = 5000;
  int geoReadings = 0;

  final streamSubscriptions = <StreamSubscription<dynamic>>[];

  final List<Map<String, dynamic>> sensorData = [];
  final List<Position?> geoLoc = [];
  final List<double> speedRead = [];

  Position? prevGeoLocSpeedComp;

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

  double get currentSpeed {
    return speedRead.isNotEmpty ? speedRead.last : -1;
  }
  // Métodos auxiliares

  List<double> updateGeoData(double currLat, currLong, prevLat, prevLong) {
    if (geoLoc.length == 5000) {
      geoLoc.clear();
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
    if (speedRead.length == 5000) {
      speedRead.removeAt(0);
    }

    if (prevGeoLocSpeedComp != null) {
      double currSpeed = computeSpeed(
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
      /* currSpeed = speedRead.last * 0.8 + currSpeed * 0.2; */

      setState(() {
        if (geoLoc.isNotEmpty) {
          prevGeoLocSpeedComp = geoLoc.last;
        }
        speedRead.add(currSpeed);
      });
    }
  }

  Future<void> storeGeoData() async {
    grantLocationPermission();
    final double prevLat = geoLoc.isEmpty ? 0 : geoLoc.last!.latitude;
    final double prevLong = geoLoc.isEmpty ? 0 : geoLoc.last!.longitude;

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position newRead = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // double currLat = double.parse(newRead.latitude.toStringAsPrecision(10));
    // double currLong = double.parse(newRead.longitude.toStringAsPrecision(10));

    var newGeoFilt = [newRead.latitude, newRead.longitude];

    if (prevLat != 0 && prevLong != 0) {
      newGeoFilt =
          updateGeoData(newRead.latitude, newRead.longitude, prevLat, prevLong);
    }

    // Actualizar lecturas de velocidad y coordenadas.

    final readFiltered = Position(
      latitude: newGeoFilt[0],
      longitude: newGeoFilt[1],
      timestamp: newRead.timestamp,
      accuracy: newRead.accuracy,
      altitude: newRead.altitude,
      heading: newRead.heading,
      speed: newRead.speed,
      speedAccuracy: newRead.speedAccuracy,
    );

    prevGeoLocSpeedComp ??= readFiltered;

    setState(() {
      geoLoc.add(readFiltered);
    });
  }

  Future<void> storeSensorData() async {
    /* final newAccelFilt = updateAccelData( */
    /*     currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ); */
    final double accelReadX = double.parse(accelEvent.x.toStringAsPrecision(6));
    final double accelReadY = double.parse(accelEvent.y.toStringAsPrecision(6));
    final double accelReadZ = double.parse(accelEvent.z.toStringAsPrecision(6));

    final AccelerometerData accelData = AccelerometerData(
        x: accelReadX,
        y: accelReadY,
        z: accelReadZ,
        samplingRate: accelReadIntervals);

    final double gyroReadX = double.parse(accelEvent.x.toStringAsPrecision(6));
    final double gyroReadY = double.parse(accelEvent.y.toStringAsPrecision(6));
    final double gyroReadZ = double.parse(accelEvent.z.toStringAsPrecision(6));

    final GyroscopeData gyroData = GyroscopeData(
        x: gyroReadX,
        y: gyroReadY,
        z: gyroReadZ,
        samplingRate: accelReadIntervals);

    if (sensorData.length == 10) {
      await collectedData.saveToJson(
          '$mainDirectory/${subdirectories[0]}', sensorData);
      sensorData.clear();
    }

    setState(() {
      if (currentPosition != null) {
        sensorData.add({
          'accelerometer': accelData.values,
          'gyroscope': gyroData.values,
          'gps': {
            'latitude': currentPosition!.latitude,
            'longitude': currentPosition!.longitude
          },
          'speed': currentSpeed,
          'sampling': accelReadIntervals
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

  // Subscripciones a los eventos del giroscopio y acelerómetro

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
      makeAppFolders(mainDirectory, subdirectories);
      collectedData.saveToJson2(
          '$mainDirectory/${subdirectories[1]}', currentPosition!);
    }
  }

  void startTimers() {
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
      geoReadings++;
      if (geoReadings == 5) {
        geoReadings = 0;
        accelTimer.cancel();
        geoLocTimer.cancel();

        accelTimer =
            Timer.periodic(Duration(milliseconds: accelReadIntervals), (timer) {
          storeSensorData();
        });

        geoLocTimer = Timer.periodic(
            Duration(milliseconds: geoLocReadIntervals), (timer) {
          storeGeoData();
        });
      }
    });
  }

  void switchScanning() async {
    setState(() {
      scanning = !scanning;
    });

    if (!scanning) {
      if (sensorData.isNotEmpty) {
        makeAppFolders(mainDirectory, subdirectories);
        await collectedData.saveToJson(
            '$mainDirectory/${subdirectories[0]}', sensorData);
      }

      prevGeoLocSpeedComp = null;
      sensorData.clear();
      geoLoc.clear();
      speedRead.clear();
    } else {
      String fileName = '$mainDirectory/${subdirectories[0]}/bumps.json';
      await collectedData.deleteFile(fileName);
    }
    switchTimerAndEvents();
  }

  void switchTimerAndEvents() {
    if (scanning) {
      startTimers();
      /* speedTimer = Timer.periodic( */
      /*     const Duration(milliseconds: speedReadIntervals), (timer) { */
      /* }); */

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
      speedTimer.cancel();
      for (var subscription in streamSubscriptions) {
        subscription.pause();
      }
    }
  }

  // Método para construir el Widget

  @override
  Widget build(BuildContext context) {
    makeAppFolders(mainDirectory, subdirectories)
        .then((value) => grantLocationPermission());

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
              'Speed',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Text(
            speedRead.isEmpty ? 'None' : '${speedRead.last} km/h',
            style: TextStyle(
                fontSize: 24,
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
              'Accel X',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              sensorData.isNotEmpty
                  ? '${sensorData.last['accelerometer'][0]}'
                  : 'None',
              style: const TextStyle(fontSize: 18, color: Colors.purple),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Accel y',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              sensorData.isNotEmpty
                  ? '${sensorData.last['accelerometer'][1]}'
                  : 'None',
              style: const TextStyle(fontSize: 18, color: Colors.purple),
            ),
          ],
        ),
      ]),
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
                      makeAppFolders(mainDirectory, subdirectories);
                      collectedData.exportData(
                          '$mainDirectory/${subdirectories[2]}',
                          filename,
                          '$mainDirectory/${subdirectories[0]}');

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
