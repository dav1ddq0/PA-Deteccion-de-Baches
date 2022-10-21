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
import 'utils/storage_utils.dart';

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

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

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
            Tab(icon: Icon(Icons.map, color: Colors.blue[200]))
          ],
          controller: controller,
          indicatorColor: Colors.blue[200],
        ),
      ),
      body: TabBarView(
        children: <Widget>[HomeTab(), MapTab()],
        controller: controller,
      ),
    );
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
