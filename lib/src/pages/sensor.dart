import 'package:deteccion_de_baches/src/pages/sensors/speed.dart';
import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/pages/sensors/gps.dart';
import 'package:deteccion_de_baches/src/pages/sensors/accelerometer.dart';
import 'package:deteccion_de_baches/src/pages/sensors/gyroscope.dart';
class SensorTab extends StatefulWidget {
  String latitude;
  String longitude;
  String speedRead;
  String accelX;
  String accelY;
  String accelZ;
  // String gyroX;
  // String gyroY;
  // String gyroZ;
  SensorTab({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.speedRead,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    // required this.gyroX,
    // required this.gyroY,
    // required this.gyroZ,
    }) : super(key: key);

  @override
  State<SensorTab> createState() => _SensorTabState();
}

class _SensorTabState extends State<SensorTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:Column(
        children: [SpeedSensor(speed:widget.speedRead), 
        GPSSensor(latitude: widget.latitude, longitude: widget.longitude), 
        AccelerometerSensor(x: widget.accelX, y: widget.accelY, z: widget.accelZ), 
        GyroscopeSensor()]
      )
    );
  }
}