import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:deteccion_de_baches/src/utils/accelerometer_data.dart';
import 'package:deteccion_de_baches/src/utils/gyroscope_data.dart';
import 'package:deteccion_de_baches/src/recorder_button.dart';
import 'package:deteccion_de_baches/src/pages/save_data_widget.dart';
import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:deteccion_de_baches/src/utils/permissions.dart';
import 'package:deteccion_de_baches/src/utils/saved_data.dart';
import 'package:deteccion_de_baches/src/utils/signal_processing.dart';
import 'package:deteccion_de_baches/src/utils/tools.dart';
import 'package:deteccion_de_baches/src/utils/storage_utils.dart';
import 'package:deteccion_de_baches/src/pages/sensors.dart';
import 'package:deteccion_de_baches/src/pages/mark_anomaly_widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  late bool scanning;
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
  final List<String> items = ["normal", "turn left", "turn right", "stop"];
  String? selectedItem = "normal";
  Position? prevGeoLocSpeedComp;

  late Timer accelTimer;
  late Timer speedTimer;
  late Timer geoLocTimer;

  late GyroscopeEvent gyroEvent;
  late AccelerometerEvent accelEvent;
  late JData collectedData;
  String recordLabel = "normal";
  bool bumpDetected = false;

  @override
  void initState() {
    super.initState();
    fileNameController = TextEditingController();
    scanning = false;
    collectedData = JData();
    milliseconds = 0;
    // _stopwatch = Stopwatch();
    // _timer = new Timer.periodic(new Duration(milliseconds: 30), (timer) {
    //   setState(() {});
    // });
  }

  // Return the current posution of the device (currernt GPS location)
  Position? get currentPosition {
    return geoLoc.isNotEmpty ? geoLoc.last : null;
  }

  // Return the current speed of the car
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
      await collectedData.saveRecordToJson(
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
          'sampling': accelReadIntervals,
          'label': selectedItem as String,
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

  void startAccelTimer() {
    accelTimer =
        Timer.periodic(Duration(milliseconds: accelReadIntervals), (timer) {
      storeSensorData();
    });
  }

  void startGeoTimer() {
    geoLocTimer =
        Timer.periodic(Duration(milliseconds: geoLocReadIntervals), (timer) {
      storeGeoData();
    });
  }

  void startTimers() {
    startAccelTimer();
    startGeoTimer();

    speedTimer = Timer.periodic(
        const Duration(milliseconds: speedReadIntervals), (timer) {
      updateSpeedRead();
      geoReadings++;
      if (geoReadings == 5) {
        geoReadings = 0;
        accelTimer.cancel();
        geoLocTimer.cancel();

        startAccelTimer();
        startGeoTimer();
      }
    });
  }

  void switchScanning() async {
    if (!scanning) {
      if (sensorData.isNotEmpty) {
        makeAppFolders(mainDirectory, subdirectories);
        await collectedData.saveRecordToJson(
            '$mainDirectory/${subdirectories[0]}', sensorData);
      }

      prevGeoLocSpeedComp = null;
      sensorData.clear();
      geoLoc.clear();
      speedRead.clear();
    } else {
      String fileName = '$mainDirectory/${subdirectories[0]}/record.json';
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

  // Widgets

  // GPS Widget
  Widget gpsWidget() {
    return GPSSensor(
        latitude: geoLoc.isNotEmpty ? '${geoLoc.last?.latitude}' : 'None',
        longitude: geoLoc.isNotEmpty ? '${geoLoc.last?.longitude}' : 'None');
  }

  // Speed Widget
  Widget speedWidget() {
    return SpeedSensor(speed: speedRead.isEmpty ? 'None' : '${speedRead.last}');
  }

  Widget acceWidget() {
    return AccelerometerSensor(
        x: sensorData.isNotEmpty
            ? '${sensorData.last['accelerometer'][0]}'
            : 'None',
        y: sensorData.isNotEmpty
            ? '${sensorData.last['accelerometer'][1]}'
            : 'None',
        z: sensorData.isNotEmpty
            ? '${sensorData.last['accelerometer'][2]}'
            : 'None');
  }

  Widget gyroWidget() {
    return GyroscopeSensor(
        x: sensorData.isNotEmpty
            ? '${sensorData.last['gyroscope'][0]}'
            : 'None',
        y: sensorData.isNotEmpty
            ? '${sensorData.last['gyroscope'][1]}'
            : 'None',
        z: sensorData.isNotEmpty
            ? '${sensorData.last['gyroscope'][2]}'
            : 'None');
  }

  Widget cancelAButton() {
    return TextButton.icon(
        label: const Text("Cancel", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.cancel, color: Colors.red),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  SnackBar _emptyALabel() {
    const SnackBar _snackBar = SnackBar(
      backgroundColor: Colors.black,
      duration: Duration(seconds: 2),
      content: Text('Please enter a label for the anomaly detected',
          style: TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(left: 40.0, right: 40),
    );
    return _snackBar;
  }

  // Widget markAnomalydDialog() {
  //   return AlertDialog(
  //     title: const Text('Anomaly detected'),
  //     content: TextFormField(
  //       controller: fileNameController,
  //       decoration: const InputDecoration(
  //           border: OutlineInputBorder(),
  //           hintText: 'Choose a name for this anomaly',
  //           prefixIcon: Icon(Icons.label)),
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           return 'Please enter a label name for the anomaly detected';
  //         }
  //         return null;
  //       },
  //     ),
  //     actions: <Widget>[markAButton(), cancelAButton()],
  //   );
  // }

  Widget saveButtonsRow() {
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [],
        ));
  }

  @override
  bool get wantKeepAlive => true;

  Widget recorderRowButton() {
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        child: RecorderButton(callback: callbackRecorder));
  }

  Widget saveData() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        SaveDataDialog(
            time: milliseconds,
            scanning: scanning,
            mainDirectory: mainDirectory,
            subdirectories: subdirectories),
        const SizedBox(width: 20),
        MarkAnomaly(
            mainDirectory: mainDirectory,
            subdirectories: subdirectories,
            position: currentPosition)
      ]),
    );
  }

  Widget stateDrapdownButton(){
    return SizedBox(
      width: 300,
      child:DropdownButtonFormField<String>(
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(width: 3, color: PotholeColor.primary)),
                        iconColor: PotholeColor.primary),
            value: selectedItem,
            items: items
                .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: TextStyle(fontSize: 16, color: Colors.white))))
                .toList(),
            onChanged: (item) => setState(() {
                  selectedItem = item;
                })) ,
    );
  }

  Widget specialEventsRow() {
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        child: stateDrapdownButton(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(children: [
        recorderRowButton(),
        saveData(),
        const StateName(),
        specialEventsRow(),
        const SensorName(),
        speedWidget(),
        gpsWidget(),
        acceWidget(),
        gyroWidget(),
      ])),
    );
  }
}

class StateName extends StatelessWidget {
  const StateName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      child: Text("State:",
          style: TextStyle(fontSize: 40, color: PotholeColor.primary)),
    );
  }
}