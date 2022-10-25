import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:flutter/material.dart';

class SensorName extends StatelessWidget {
  const SensorName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      child: Text("Sensors:",
          style: TextStyle(fontSize: 40, color: PotholeColor.primary)),
    );
  }
}

class GPSSensor extends StatelessWidget {
  final String latitude;
  final String longitude;

  const GPSSensor({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: PotholeColor.primary, size: 37),
                Text("GPS:",
                    style: TextStyle(color: PotholeColor.primary, fontSize: 18)),
              ],
            ),
            LatLngRowWidget(name: "Lat", value: latitude),
            LatLngRowWidget(name: "Lng", value: longitude)
          ],
        ));
  }
}



class SpeedSensor extends StatelessWidget {
  final String speed;
  const SpeedSensor({required this.speed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.speed_rounded, color: PotholeColor.primary, size: 37),
          const SizedBox(width: 8),
          Text("Speed:",
              style: TextStyle(color: PotholeColor.primary, fontSize: 18)),
          const SizedBox(width: 8),
          Text("$speed  km/h",
              style: TextStyle(color: PotholeColor.primary, fontSize: 18))
        ],
      ),
    );
  }
}

class GyroscopeSensor extends StatelessWidget {
  final String x;
  final String y;
  final String z;

  const GyroscopeSensor({
    Key? key,
    required this.x,
    required this.y,
    required this.z,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(Icons.rotate_left_rounded,
                  color: PotholeColor.primary, size: 37),
              Text(
                "Gyroscope: ",
                style: TextStyle(color: PotholeColor.primary, fontSize: 18),
              )
            ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AxisRowWidget(axisTag: "X Axis:", lecture: x),
                AxisRowWidget(axisTag: "Y Axis:", lecture: y),
                AxisRowWidget(axisTag: "Z Axis:", lecture: z)
              ],
            ),
          ],
        ));
  }
}

class AccelerometerSensor extends StatelessWidget {
  final String x;
  final String y;
  final String z;

  const AccelerometerSensor({
    Key? key,
    required this.x,
    required this.y,
    required this.z,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.directions_run, color: PotholeColor.primary, size: 37),
              Text(
                "Accelerometer: ",
                style: TextStyle(color: PotholeColor.primary, fontSize: 18),
              )
            ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AxisRowWidget(axisTag: "X Axis:", lecture: x),
                AxisRowWidget(axisTag: "Y Axis:", lecture: y),
                AxisRowWidget(axisTag: "Z Axis:", lecture: z),
              ],
            )
            
          ],
        ));
  }
}

class LatLngRowWidget extends StatelessWidget {
  final String name;
  final String value;
  const LatLngRowWidget({required this.name, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$name:",
          style: TextStyle(color: PotholeColor.primary, fontSize: 20),
        ),
        const SizedBox(width: 8),
        Text(
          value.toString(),
          style: TextStyle(color: PotholeColor.primary, fontSize: 20),
        )
      ],
    );
  }
}

class AxisRowWidget extends StatelessWidget {
  final String axisTag;
  final String lecture;
  const AxisRowWidget({required this.axisTag, required this.lecture, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(children: [
        Text(
          axisTag,
          style: TextStyle(fontSize: 18, color: PotholeColor.primary),
        ),
        const SizedBox(width: 8),
        Text(lecture.toString(),
            style: TextStyle(fontSize: 18, color: PotholeColor.primary))
      ]),
    );
  }
}
