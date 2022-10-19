import 'dart:math';
import 'package:flutter/material.dart';

class GyroscopeSensor extends StatefulWidget {
  GyroscopeSensor({Key? key}) : super(key: key);

  @override
  State<GyroscopeSensor> createState() => _GyroscopeSensorState();
}

class _GyroscopeSensorState extends State<GyroscopeSensor> {
  late double x = 10.4;
  late double y = 67;
  late double z = 10.6;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(Icons.rotate_left_rounded,
                  color: Colors.blue[200], size: 37),
              Text(
                "Gyroscope: ",
                style: TextStyle(color: Colors.blue[200], fontSize: 18),
              )
            ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AccAxisRowWidget(axisTag: "X Axis:", lecture: x),
                AccAxisRowWidget(axisTag: "Y Axis:", lecture: y),
                AccAxisRowWidget(axisTag: "Z Axis:", lecture: z)
              ],
            ),
            // ElevatedButton(
            //     onPressed: () {
            //       setState(() {
            //         x = Random().nextDouble() * Random().nextInt(20);
            //       });
            //     },
            //     child: Icon(Icons.lock_open_outlined))
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
