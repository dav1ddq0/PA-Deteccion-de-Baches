class GPSData {
  double latitude;
  double longitude;
  int samplingRate;

  GPSData(
      {required this.latitude,
      required this.longitude,
      required this.samplingRate});

  @override
  String toString() {
    return 'GPS{latitude: $latitude, longitude: $longitude}';
  }

  List<double> get values => [latitude, longitude];
}
