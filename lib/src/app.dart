import 'dart:async';

import 'package:deteccion_de_baches/src/pages/stopwatch.dart';
import 'package:deteccion_de_baches/src/utils/accelerometer_data.dart';
import 'package:deteccion_de_baches/src/utils/permissions.dart';
import 'package:deteccion_de_baches/src/utils/saved_data.dart';
import 'package:deteccion_de_baches/src/utils/signal_processing.dart';
import 'package:deteccion_de_baches/src/utils/tools.dart';
import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/recorder_button.dart';
import 'package:deteccion_de_baches/src/pages/map.dart';
import 'package:deteccion_de_baches/src/pages/home.dart';
import 'package:deteccion_de_baches/src/pages/sensor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'utils/gyroscope_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pothole Recorder',
      home: PotholeApp(),
      theme: ThemeData.dark(),
      // home: MyHomePage(title: 'Bump Record2'),
    );
  }
}

class PotholeApp extends StatefulWidget {
  PotholeApp({Key? key}) : super(key: key);

  @override
  State<PotholeApp> createState() => _PotholeState();
}

class _PotholeState extends State<PotholeApp>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  late bool scanning;
  IconData playIcon = Icons.play_arrow;
  IconData stopIcon = Icons.stop;
  String playText = "Start Recorder";
  String stopText = "Stop Recorder";
  late int milliseconds;
  late TextEditingController fileNameController;
  final String mainDirectory =
      '/storage/emulated/0/Baches'; // path where json data is stored
  final List<String> subdirectories = ['sensors', 'mark_labels', 'exported'];

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
  late AccelerometerEvent accelEvent;
  JData collectedData = JData();
  bool bumpDetected = false;

  Position? get currentPosition {
    return geoLoc.isNotEmpty ? geoLoc.last : null;
  }

  double get currentSpeed {
    return speedRead.isNotEmpty ? speedRead.last : -1;
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

  List<double> updateGeoData(double currLat, currLong, prevLat, prevLong) {
    if (geoLoc.length == 5000) {
      geoLoc.clear();
    }

    return biAxialLowpassFilter(prevLat, prevLong, currLat, currLong);
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

  void subscribeAccelEventListener() {
    streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
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
  // late Timer _timer;
  // late Stopwatch _stopwatch;

  callbackRecorder(nScanning) {


    setState(() {
      scanning = nScanning;
      switchScanning();
    });
  }

  callbackStopwatch(crono) {
    milliseconds = crono;
  }

  @override
  void initState() {
    super.initState();
    fileNameController = TextEditingController();
    controller = TabController(length: 3, vsync: this);
    scanning = false;
    // _stopwatch = Stopwatch();
    // _timer = new Timer.periodic(new Duration(milliseconds: 30), (timer) {
    //   setState(() {});
    // });
  }

  @override
  bool get wantKeepAlive => true;

  // void handleStartStop() {
  //   if (_stopwatch.isRunning) {
  //     _stopwatch.stop();
  //     _stopwatch.reset();
  //   } else {
  //     _stopwatch.start();
  //   }

  //   setState(() {});
  // }
  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

  // int get clockTime => _stopwatch !=  null?_stopwatch.elapsedMilliseconds: 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pothole Recorder'),
          bottom: TabBar(
            indicatorPadding: const EdgeInsets.all(5),
            indicator: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue[50],
            ),
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home, color: Colors.blue[200])),
              Tab(icon: Icon(Icons.sensors, color: Colors.blue[200])),
              Tab(icon: Icon(Icons.map, color: Colors.blue[200]))
            ],
            controller: controller,
            indicatorColor: Colors.blue[200],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            HomeTab(scanning: scanning),
            SensorTab(
              latitude: geoLoc.isNotEmpty ? '${geoLoc.last?.latitude}' : 'None',
              longitude:
                  geoLoc.isNotEmpty ? '${geoLoc.last?.longitude}' : 'None',
              speedRead:speedRead.isEmpty ? 'None' : '${speedRead.last} km/h',
              accelX: sensorData.isNotEmpty
                  ? '${sensorData.last['accelerometer'][0]}'
                  : 'None',
              accelY: sensorData.isNotEmpty
                  ? '${sensorData.last['accelerometer'][1]}'
                  : 'None',
              accelZ: sensorData.isNotEmpty
                  ? '${sensorData.last['accelerometer'][2]}'
                  : 'None',
            ),
            MapTab()
          ],
          controller: controller,
        ),
        floatingActionButton: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            child: RecorderButton(callback: callbackRecorder)));
  }
}


// class StopwatchContainerW extends StatelessWidget {
//   final bool scanning;
//   final int milliseconds;
//   const StopwatchContainerW({required this.scanning, required this.milliseconds, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return scanning ? MyStopwatchButton(milliseconds:milliseconds) : const SizedBox(width: 0);
//   }
// }
// class StopwatchButtonW extends StatefulWidget {
//   final bool scanning;
//   final int milliseconds;
//   StopwatchButtonW({required this.scanning, Key? key}) : super(key: key);

//   @override
//   State<StopwatchButtonW> createState() => _StopwatchButtonWState();
// }

// class _StopwatchButtonWState extends State<StopwatchButtonW> {
//   @override
//   Widget build(BuildContext context) {
//     return widget.scanning ? MyStopwatchWidget() : SizedBox(width: 0);
//   }
// }
