import 'dart:async';

import 'package:deteccion_de_baches/src/pages/stopwatch.dart';
import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/recorder_button.dart';
import 'package:deteccion_de_baches/src/pages/map.dart';
import 'package:deteccion_de_baches/src/pages/home.dart';
import 'package:deteccion_de_baches/src/pages/sensor.dart';

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
  late RecorderButton recorderButton;
  late bool scanning;
  IconData playIcon = Icons.play_arrow;
  IconData stopIcon = Icons.stop;
  String playText = "Start Recorder";
  String stopText = "Stop Recorder";
  late int milliseconds;
  // late Timer _timer;
  // late Stopwatch _stopwatch;

  callbackRecorder(nScanning) {
    setState((){
      scanning = nScanning;
    });
    
  }
  callbackStopwatch(crono) {
    setState((){
      milliseconds = crono;
    });
    
  }

  @override
  void initState() {
    super.initState();
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
            SensorTab(),
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
