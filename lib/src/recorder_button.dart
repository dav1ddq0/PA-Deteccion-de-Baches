import 'dart:async';

import 'package:flutter/material.dart';

String formatTime(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}

class RecorderButton extends StatefulWidget {
  final Function callback;
  const RecorderButton({required this.callback, Key? key}) : super(key: key);

  @override
  State<RecorderButton> createState() => _RecorderButtonState();
}

class _RecorderButtonState extends State<RecorderButton> {
  bool pressed = false;
  IconData playIcon = Icons.play_arrow;
  IconData stopIcon = Icons.stop;
  String playText = "Start Recorder";
  String stopText = "Stop Recorder";
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
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(width: 10),
      Container(
        margin: EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: () {
            handleStartStop();
            setState(() {
              pressed = !pressed;
              widget.callback(pressed);
            });
          },
          child: Text(pressed ? stopText : playText),
          style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              padding: EdgeInsets.all(15),
              textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),

        // StopwatchContainerW(scanning: scanning, milliseconds: 1000)
      ),
      SizedBox(width: 20),
      pressed
          ? StopwatchButton(milliseconds: _stopwatch.elapsedMilliseconds)
          : const SizedBox(width: 0)
    ]);
  }
}

class StopwatchButton extends StatelessWidget {
  final int milliseconds;
  const StopwatchButton({required this.milliseconds, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (ElevatedButton(
        onPressed: () {},
        child: Text(formatTime(milliseconds), style: TextStyle(fontSize: 18.0)),
        style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.all(15),
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))));
  }
}
