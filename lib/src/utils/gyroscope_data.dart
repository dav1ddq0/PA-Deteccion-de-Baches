class GyroscopeData {
  double x;
  double y;
  double z;
  int samplingRate;

  GyroscopeData({
      required this.x,
      required this.y,
      required this.z,
      required this.samplingRate
      }
  );

  @override
  String toString() {
    return 'Gyroscope{x: $x, y: $y, z: $z}';
  }

  List<double> get values => [x, y, z];
}
