import 'dart:async';

import 'package:flutter/material.dart';

String formatTime(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}

class MyStopwatchWidget extends StatefulWidget {
  MyStopwatchWidget({Key? key}) : super(key: key);

  
  @override
  State<MyStopwatchWidget> createState() => _MyStopwatchWidgetState();
}

class _MyStopwatchWidgetState extends State<MyStopwatchWidget> {
  late Timer _timer;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = new Timer.periodic(new Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

 
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void handleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _stopwatch.reset();
    } else {
      _stopwatch.start();
    }

    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(formatTime(_stopwatch.elapsedMilliseconds), style: TextStyle(fontSize:25.0));
            
        
      
    
  }
}