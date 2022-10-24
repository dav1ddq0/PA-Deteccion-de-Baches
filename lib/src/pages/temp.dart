// / Accelerometer Widget

//   Widget accelerometerWidget(String x, String y, String z) {
//     return Container(
//         margin: EdgeInsets.all(8),
//         padding: EdgeInsets.all(10),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Row(children: [
//               Icon(Icons.directions_run, color: Colors.blue[200], size: 37),
//               Text(
//                 "Accelerometer: ",
//                 style: TextStyle(color: Colors.blue[200], fontSize: 18),
//               )
//             ]),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 AxisRowWidget(axisTag: "X Axis:", lecture: x),
//                 AxisRowWidget(axisTag: "Y Axis:", lecture: y),
//                 AxisRowWidget(axisTag: "Z Axis:", lecture: z),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   // x = Random().nextDouble() * Random().nextInt(20);
//                 });
//               },
//               child: Icon(Icons.graphic_eq),
//               style: ElevatedButton.styleFrom(
//                   shape: CircleBorder(),
//                   padding: EdgeInsets.all(8),
//                   textStyle:
//                       TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//             )
//           ],
//         ));
//   }

  // Widget gyroscopeWidget(String x, String y, String z) {
  //   return Container(
  //       margin: EdgeInsets.all(8),
  //       padding: EdgeInsets.all(10),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Row(children: [
  //             Icon(Icons.rotate_left_rounded,
  //                 color: Colors.blue[200], size: 37),
  //             Text(
  //               "Gyroscope: ",
  //               style: TextStyle(color: Colors.blue[200], fontSize: 18),
  //             )
  //           ]),
  //           Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               AxisRowWidget(axisTag: "X Axis:", lecture: x),
  //               AxisRowWidget(axisTag: "Y Axis:", lecture: y),
  //               AxisRowWidget(axisTag: "Z Axis:", lecture: z)
  //             ],
  //           ),
  //         ],
  //       ));
  // }




// SensorTab(
//               latitude: geoLoc.isNotEmpty ? '${geoLoc.last?.latitude}' : 'None',
//               longitude:
//                   geoLoc.isNotEmpty ? '${geoLoc.last?.longitude}' : 'None',
//               speedRead:speedRead.isEmpty ? 'None' : '${speedRead.last}',
//               accelX: sensorData.isNotEmpty
//                   ? '${sensorData.last['accelerometer'][0]}'
//                   : 'None',
//               accelY: sensorData.isNotEmpty
//                   ? '${sensorData.last['accelerometer'][1]}'
//                   : 'None',
//               accelZ: sensorData.isNotEmpty
//                   ? '${sensorData.last['accelerometer'][2]}'
//                   : 'None',
//             )

              // Tab(icon: Icon(Icons.sensors, color: Colors.blue[200]))



     // Return the current posution of the device (currernt GPS location)
  // Position? get currentPosition {
  //   return geoLoc.isNotEmpty ? geoLoc.last : null;
  // }
  // // Return the current speed of the car
  // double get currentSpeed {
  //   return speedRead.isNotEmpty ? speedRead.last : -1;
  // }

  // Future<void> storeSensorData() async {
  //   /* final newAccelFilt = updateAccelData( */
  //   /*     currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ); */
  //   final double accelReadX = double.parse(accelEvent.x.toStringAsPrecision(6));
  //   final double accelReadY = double.parse(accelEvent.y.toStringAsPrecision(6));
  //   final double accelReadZ = double.parse(accelEvent.z.toStringAsPrecision(6));

  //   final AccelerometerData accelData = AccelerometerData(
  //       x: accelReadX,
  //       y: accelReadY,
  //       z: accelReadZ,
  //       samplingRate: accelReadIntervals);

  //   final double gyroReadX = double.parse(accelEvent.x.toStringAsPrecision(6));
  //   final double gyroReadY = double.parse(accelEvent.y.toStringAsPrecision(6));
  //   final double gyroReadZ = double.parse(accelEvent.z.toStringAsPrecision(6));

  //   final GyroscopeData gyroData = GyroscopeData(
  //       x: gyroReadX,
  //       y: gyroReadY,
  //       z: gyroReadZ,
  //       samplingRate: accelReadIntervals);

  //   if (sensorData.length == 10) {
  //     await collectedData.saveRecordToJson(
  //         '$mainDirectory/${subdirectories[0]}', sensorData);
  //     sensorData.clear();
  //   }

  //   setState(() {
  //     if (currentPosition != null) {
  //       sensorData.add({
  //         'accelerometer': accelData.values,
  //         'gyroscope': gyroData.values,
  //         'gps': {
  //           'latitude': currentPosition!.latitude,
  //           'longitude': currentPosition!.longitude
  //         },
  //         'speed': currentSpeed,
  //         'sampling': accelReadIntervals
  //       });

  //       /* accelRead */
  //       /*     .add(AccelerometerData(x: currReadX, y: currReadY, z: currReadZ)); */
  //       /* if (prevReadX != 0) { */
  //       /*   bumpDetected = scanPotholes( */
  //       /*       prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ); */
  //       /*   if (bumpDetected) { */
  //       /*     HapticFeedback.vibrate(); */
  //       /*   } */
  //       /* } */
  //     }
  //   });
  // }

  // List<double> updateGeoData(double currLat, currLong, prevLat, prevLong) {
  //   if (geoLoc.length == 5000) {
  //     geoLoc.clear();
  //   }

  //   return biAxialLowpassFilter(prevLat, prevLong, currLat, currLong);
  // }

  // Future<void> storeGeoData() async {
  //   grantLocationPermission();
  //   final double prevLat = geoLoc.isEmpty ? 0 : geoLoc.last!.latitude;
  //   final double prevLong = geoLoc.isEmpty ? 0 : geoLoc.last!.longitude;

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   Position newRead = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);

  //   // double currLat = double.parse(newRead.latitude.toStringAsPrecision(10));
  //   // double currLong = double.parse(newRead.longitude.toStringAsPrecision(10));

  //   var newGeoFilt = [newRead.latitude, newRead.longitude];

  //   if (prevLat != 0 && prevLong != 0) {
  //     newGeoFilt =
  //         updateGeoData(newRead.latitude, newRead.longitude, prevLat, prevLong);
  //   }

  //   // Actualizar lecturas de velocidad y coordenadas.

  //   final readFiltered = Position(
  //     latitude: newGeoFilt[0],
  //     longitude: newGeoFilt[1],
  //     timestamp: newRead.timestamp,
  //     accuracy: newRead.accuracy,
  //     altitude: newRead.altitude,
  //     heading: newRead.heading,
  //     speed: newRead.speed,
  //     speedAccuracy: newRead.speedAccuracy,
  //   );

  //   prevGeoLocSpeedComp ??= readFiltered;

  //   setState(() {
  //     geoLoc.add(readFiltered);
  //   });
  // }

  // Future<void> updateSpeedRead() async {
  //   if (speedRead.length == 5000) {
  //     speedRead.removeAt(0);
  //   }

  //   if (prevGeoLocSpeedComp != null) {
  //     double currSpeed = computeSpeed(
  //         prevGeoLocSpeedComp!.latitude,
  //         prevGeoLocSpeedComp!.longitude,
  //         geoLoc.last!.latitude,
  //         geoLoc.last!.longitude,
  //         (speedReadIntervals / 1000));

  //     if (currSpeed != 0) {
  //       double newSamplingRate = recomputeSamplingRate(1, currSpeed);
  //       accelReadIntervals = (1000 * newSamplingRate).floor();
  //       geoLocReadIntervals = (1000 * newSamplingRate).floor();
  //     }
  //     /* currSpeed = speedRead.last * 0.8 + currSpeed * 0.2; */

  //     setState(() {
  //       if (geoLoc.isNotEmpty) {
  //         prevGeoLocSpeedComp = geoLoc.last;
  //       }
  //       speedRead.add(currSpeed);
  //     });
  //   }
  // }


  // void startAccelTimer(){
  //   accelTimer =
  //       Timer.periodic(Duration(milliseconds: accelReadIntervals), (timer) {
  //     storeSensorData();
  //   });
  // }

  // void startGeoTimer() {
  //   geoLocTimer =
  //       Timer.periodic(Duration(milliseconds: geoLocReadIntervals), (timer) {
  //     storeGeoData();
  //   });
  // }


  // void startTimers() {

  //   startAccelTimer();
  //   startGeoTimer();
    
  //   speedTimer = Timer.periodic(
  //       const Duration(milliseconds: speedReadIntervals), (timer) {
  //     updateSpeedRead();
  //     geoReadings++;
  //     if (geoReadings == 5) {
  //       geoReadings = 0;
  //       accelTimer.cancel();
  //       geoLocTimer.cancel();

  //       startAccelTimer();
  //       startGeoTimer();
  //     }
  //   });
  // }

  // void switchScanning() async {
  //   if (!scanning) {
  //     if (sensorData.isNotEmpty) {
  //       makeAppFolders(mainDirectory, subdirectories);
  //       await collectedData.saveRecordToJson(
  //           '$mainDirectory/${subdirectories[0]}', sensorData);
  //     }

  //     prevGeoLocSpeedComp = null;
  //     sensorData.clear();
  //     geoLoc.clear();
  //     speedRead.clear();
  //   } else {
  //     String fileName = '$mainDirectory/${subdirectories[0]}/bumps.json';
  //     await collectedData.deleteFile(fileName);
  //   }
  //   switchTimerAndEvents();
  // }

  // void subscribeAccelEventListener() {
  //   streamSubscriptions
  //       .add(accelerometerEvents.listen((AccelerometerEvent event) {
  //     setState(() {
  //       accelEvent = event;
  //     });
  //   }));
  // }

  // void subscribeGyroEventListener() {
  //   streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
  //     setState(() {
  //       gyroEvent = event;
  //     });
  //   }));
  // }

  // void switchTimerAndEvents() {
  //   if (scanning) {
  //     startTimers();
  //     /* speedTimer = Timer.periodic( */
  //     /*     const Duration(milliseconds: speedReadIntervals), (timer) { */
  //     /* }); */

  //     if (streamSubscriptions.isEmpty) {
  //       subscribeAccelEventListener();
  //       subscribeGyroEventListener();
  //     } else {
  //       for (var subscription in streamSubscriptions) {
  //         subscription.resume();
  //       }
  //     }
  //   } else {
  //     geoLocTimer.cancel();
  //     accelTimer.cancel();
  //     speedTimer.cancel();
  //     for (var subscription in streamSubscriptions) {
  //       subscription.pause();
  //     }
  //   }
  // }
  // // late Timer _timer;
  // // late Stopwatch _stopwatch;

  // callbackRecorder(nScanning) {


  //   setState(() {
  //     scanning = nScanning;
  //     switchScanning();
  //   });
  // }

  // callbackStopwatch(crono) {
  //   milliseconds = crono;
  // }

  

  // @override
  // bool get wantKeepAlive => true;
  

  // late bool scanning;
  // late int milliseconds;
  // late TextEditingController fileNameController;
  // final String mainDirectory =
  //     '/storage/emulated/0/Baches'; // path where json data is stored
  // final List<String> subdirectories = ['sensors', 'mark_labels', 'exported'];

  // int accelReadIntervals = 1000;
  // int geoLocReadIntervals = 1000;
  // static const int speedReadIntervals = 5000;
  // int geoReadings = 0;

  // final streamSubscriptions = <StreamSubscription<dynamic>>[];

  // final List<Map<String, dynamic>> sensorData = [];
  // final List<Position?> geoLoc = [];
  // final List<double> speedRead = [];

  // Position? prevGeoLocSpeedComp;

  // late Timer accelTimer;
  // late Timer speedTimer;
  // late Timer geoLocTimer;

  // late GyroscopeEvent gyroEvent;
  // late AccelerometerEvent accelEvent;
  // late JData collectedData ;
  // bool bumpDetected = false;
