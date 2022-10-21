import 'dart:math';
import 'package:flutter/material.dart';

class AccelerometerSensor extends StatefulWidget {
  final String x;
  final String y;
  final String z ;

  AccelerometerSensor({
    Key? key,
    required this.x,
    required this.y,
    required this.z,
    }) : super(key: key);

  @override
  State<AccelerometerSensor> createState() => _AccelerometerSensorState();
}

class _AccelerometerSensorState extends State<AccelerometerSensor> {
  

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
                AxisRowWidget(axisTag: "X Axis:", lecture: widget.x),
                AxisRowWidget(axisTag: "Y Axis:", lecture: widget.y),
                AxisRowWidget(axisTag: "Z Axis:", lecture: widget.z),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // x = Random().nextDouble() * Random().nextInt(20);
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

class AxisRowWidget extends StatelessWidget {
  final String axisTag;
  final String lecture;
  const AxisRowWidget({
    required this.axisTag, 
    required this.lecture, 
    Key? key}): super(key: key); 
   


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
