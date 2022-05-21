class AccelerometerData {
  double x;
  double y;
  double z;

  AccelerometerData({required this.x, required this.y, required this.z});

  @override
  String toString() {
    return 'Accelerometer{x: $x, y: $y, z: $z}';
  }

  List<double> get values => [x, y, z];
}

var acc1 = AccelerometerData(x: 1, y: 3, z: 4);

void main() {
  print(acc1.x);
  print(acc1.y);
  print(acc1.z);
  print(acc1.values);
}
