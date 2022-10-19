import 'package:deteccion_de_baches/src/pages/sensors/speed.dart';
import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/pages/sensors/gps.dart';
import 'package:deteccion_de_baches/src/pages/sensors/accelerometer.dart';
import 'package:deteccion_de_baches/src/pages/sensors/gyroscope.dart';
class SensorTab extends StatefulWidget {
  SensorTab({Key? key}) : super(key: key);

  @override
  State<SensorTab> createState() => _SensorTabState();
}

class _SensorTabState extends State<SensorTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:Column(
        children: [SpeedSensor(speed:12), GPSSensor(), AccelerometerSensor(), GyroscopeSensor()]
      )
    );
  }
}