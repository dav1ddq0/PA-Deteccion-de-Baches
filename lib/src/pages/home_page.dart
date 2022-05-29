import 'dart:async';
import 'package:deteccion_de_baches/src/utils/scaler.dart';
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
import 'package:deteccion_de_baches/src/utils/permissions.dart';

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
    'mark_labels'
  ]; // path where sensor data is stored
  int accelReadIntervals = 100;
  int geoLocReadIntervals = 1000;

  final streamSubscriptions = <StreamSubscription<dynamic>>[];

  final List<AccelerometerData> accelRead = []; // Serie temporal acelerómetro
  final List<GyroscopeData> gyroRead = []; // Serie temporal giroscopio
  final List<Position?> geoLoc = [];
  final List<double> speedRead =
      []; // Velocidad en cada momento que se realiza una medición en km/h

  late Timer accelTimer;
  late Timer geoLocTimer;

  late GyroscopeEvent gyroEvent;
  late UserAccelerometerEvent accelEvent;
  JData collectedData = JData();

  bool scanning = false; // Para saber si la app está escaneando o no
  bool bumpDetected = false;

  @override
  void initState() {
    super.initState();
  }

  Position? get currentPosition {
    return geoLoc.isNotEmpty ? geoLoc[geoLoc.length - 1] : null;
  }
  // Métodos auxiliares

  /* Tuple2<double, double> updateGeoData( double currLat, currLong, prevLat, prevLong) { */
  /*   if (geoLoc.length == 1000) { */
  /*     geoLoc.removeAt(0); */
  /*   } */

  /*   late double currSpeed; */
  /*   if (geoLoc.length > 1) { */
  /*     var currSpeed = updateSpeedRead(prevLat, prevLong, currLat, currLong); */

  /*     if (speedRead.isEmpty) { */
  /*       currSpeed = currSpeed * 0.1; */
  /*     } else { */
  /*       currSpeed = speedRead.last * 0.9 + currSpeed * 0.1; */
  /*     } */

  /*     currSpeed = double.parse(currSpeed.toStringAsPrecision(6)); */
  /*     speedRead.add(currSpeed); */
  /*   } */

  /*   return biAxialLowpassFilter(prevLat, prevLong, currLat, currLong); */
  /* } */

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

  /* double updateSpeedRead( */
  /*     double prevLat, double prevLong, double currLat, double currLong) { */
  /*   if (speedRead.length == 1000) { */
  /*     speedRead.removeAt(0); */
  /*   } */

  /*   final double currSpeed = computeSpeed( */
  /*       prevLat, prevLong, currLat, currLong, (geoLocReadIntervals / 1000)); */
  /*   return double.parse(currSpeed.toStringAsPrecision(5)); */
  /* } */

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
        updateFilterAccelData();
        updateFilterGyroData();
      });
      geoLocTimer =
          Timer.periodic(Duration(milliseconds: geoLocReadIntervals), (timer) {
        updateFilterGeoData();
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
      if (accelRead.isNotEmpty &&
          gyroRead.isNotEmpty &&
          geoLoc.isNotEmpty &&
          !scanning) {
        collectedData.saveToJson(
            '$mainDirectory/${subdirectories[0]}', accelRead, gyroRead, geoLoc);
      }
    });

    switchTimerAndEvents();
  }

  Future<void> updateFilterGeoData() async {
    // When we reach here, permissions are granted and we can
    await grantLocationPermission();

    // continue accessing the position of the device.

    Position newRead = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // double currLat = double.parse(newRead.latitude.toStringAsPrecision(10));
    // double currLong = double.parse(newRead.longitude.toStringAsPrecision(10));

    /* final double prevLat = geoLoc.isEmpty ? 0 : geoLoc.last!.latitude; */
    /* final double prevLong = geoLoc.isEmpty ? 0 : geoLoc.last!.longitude; */

    /* var newGeoFilt = */
    /* Tuple2<double, double>(newRead.latitude, newRead.longitude); */

    /* if (prevLat != 0 && prevLong != 0) { */
    /*   newGeoFilt = */
    /*       updateGeoData(newRead.latitude, newRead.longitude, prevLat, prevLong); */
    /* } */
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

  Future<void> updateFilterAccelData() async {
    // Obtener lecturas del giroscopio y acelerómetro
    final double currReadX = double.parse(accelEvent.x.toStringAsPrecision(6));
    final double currReadY = double.parse(accelEvent.y.toStringAsPrecision(6));
    final double currReadZ = double.parse(accelEvent.z.toStringAsPrecision(6));

    final double prevReadX = accelRead.isEmpty ? 0 : accelRead.last.x;
    final double prevReadY = accelRead.isEmpty ? 0 : accelRead.last.y;
    final double prevReadZ = accelRead.isEmpty ? 0 : accelRead.last.z;

    /* final newAccelFilt = updateAccelData( */
    /*     currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ); */

    setState(() {
      accelRead
          .add(AccelerometerData(x: currReadX, y: currReadY, z: currReadZ));
      if (prevReadX != 0) {
        bumpDetected = scanPotholes(
            prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ);
        if (bumpDetected) {
          HapticFeedback.vibrate();
        }
      }
    });
  }

  Future<void> updateFilterGyroData() async {
    final double currReadX = double.parse(gyroEvent.x.toStringAsPrecision(6));
    final double currReadY = double.parse(gyroEvent.y.toStringAsPrecision(6));
    final double currReadZ = double.parse(gyroEvent.z.toStringAsPrecision(6));

    final double prevReadX = gyroRead.isEmpty ? 0 : gyroRead.last.x;
    final double prevReadY = gyroRead.isEmpty ? 0 : gyroRead.last.y;
    final double prevReadZ = gyroRead.isEmpty ? 0 : gyroRead.last.z;

    /* final newGyroFilt = updateGyroData( */
    /*     currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ); */

    setState(() {
      gyroRead.add(GyroscopeData(x: currReadX, y: currReadY, z: currReadZ));
    });
  }

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
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(
          children: [
            const Text(
              'Y axis accel is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              accelRead.isEmpty ? 'None' : '${accelRead.last.y}',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Z axis accel is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              accelRead.isEmpty ? 'None' : '${accelRead.last.z}',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
      ]),
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
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(
          children: [
            const Text(
              'Y axis gyro is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              gyroRead.isEmpty ? 'None' : '${gyroRead.last.y}',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Z axis gyro is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              gyroRead.isEmpty ? 'None' : '${gyroRead.last.z}',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
      ]),
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
          onPressed: labelAnomaly)
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
