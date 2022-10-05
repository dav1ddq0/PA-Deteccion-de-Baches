class AccelerometerData {
  double x;
  double y;
  double z;
  int samplingRate;

  AccelerometerData(
      {required this.x,
      required this.y,
      required this.z,
      required this.samplingRate});

  @override
  String toString() {
    return 'Accelerometer{x: $x, y: $y, z: $z}';
  }

  List<double> get values => [x, y, z];
  Map<String, dynamic> toJson() => {};
}
