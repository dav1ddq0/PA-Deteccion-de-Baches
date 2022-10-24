import 'package:flutter/material.dart';

class SpeedSensor extends StatefulWidget {
  final String speed;
  SpeedSensor({required this.speed, Key? key}) : super(key: key);

  @override
  State<SpeedSensor> createState() => _SpeedSensorState();
}

class _SpeedSensorState extends State<SpeedSensor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.speed_rounded, color: Colors.blue[200], size: 37),
          SizedBox(width: 8),
          Text("Speed:",
              style: TextStyle(color: Colors.blue[200], fontSize: 18)),
          SizedBox(width: 8),
          Text("${widget.speed}  km/h",
              style: TextStyle(color: Colors.blue[200], fontSize: 18))
        ],
      ),
    );
  }
}
