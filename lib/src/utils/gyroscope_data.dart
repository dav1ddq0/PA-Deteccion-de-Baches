class GyroscopeData {
  double x;
  double y;
  double z;

  GyroscopeData({required this.x, required this.y, required this.z});

  @override
  String toString() {
    return 'Gyroscope{x: $x, y: $y, z: $z}';
  }

  List<double> get values => [x, y, z];
}
