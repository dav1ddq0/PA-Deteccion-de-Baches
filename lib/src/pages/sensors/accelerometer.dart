import 'dart:math';
import 'package:flutter/material.dart';

class AccelerometerSensor extends StatefulWidget {
  AccelerometerSensor({Key? key}) : super(key: key);

  @override
  State<AccelerometerSensor> createState() => _AccelerometerSensorState();
}

class _AccelerometerSensorState extends State<AccelerometerSensor> {
  late double x = 10.4;
  late double y = 67;
  late double z = 10.6;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.directions_run, color: Colors.blue[200], size: 37),
              Text(
                "Accelerometer: ",
                style: TextStyle(color: Colors.blue[200], fontSize: 18),
              )
            ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AccAxisRowWidget(axisTag: "X Axis:", lecture: x),
                AccAxisRowWidget(axisTag: "Y Axis:", lecture: y),
                AccAxisRowWidget(axisTag: "Z Axis:", lecture: z)
              ],
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  x = Random().nextDouble() * Random().nextInt(20);
                });
              },
              child: Icon(Icons.graphic_eq),
              style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(8),
                  textStyle:
                      TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ));
  }
}

class AccAxisRowWidget extends StatelessWidget {
  late String axisTag;
  late double lecture;
  AccAxisRowWidget({required String axisTag, required double lecture, Key? key})
      : super(key: key) {
    this.axisTag = axisTag;
    this.lecture = lecture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(children: [
        Text(
          axisTag,
          style: TextStyle(fontSize: 18, color: Colors.blue[200]),
        ),
        SizedBox(width: 8),
        Text(lecture.toString(),
            style: TextStyle(fontSize: 18, color: Colors.blue[200]))
      ]),
    );
  }
}
