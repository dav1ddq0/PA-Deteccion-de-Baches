import 'dart:async';
import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:deteccion_de_baches/src/pages/stopwatch.dart';
import 'package:deteccion_de_baches/src/themes/my_style.dart';
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
import 'package:deteccion_de_baches/src/themes/pothole_dark_theme.dart';
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
      theme: myThemeDark,
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
        title: const Text('Pothole Recorder', style: TextStyle(color: PotholeColor.primary),),
        bottom: TabBar(
          indicatorPadding: const EdgeInsets.all(5),
          indicator: BoxDecoration(
            border: Border.all(color: PotholeColor.tabBarIndicatorBorderColor),
            borderRadius: BorderRadius.circular(10),
            color: PotholeColor.tabBarIndicatorMainColor,
          ),
          tabs: <Widget>[
            Tab(icon: Icon(Icons.home, color: PotholeColor.primary)),
            Tab(icon: Icon(Icons.map, color: PotholeColor.primary))
          ],
          controller: controller,
          indicatorColor: PotholeColor.primary,
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
