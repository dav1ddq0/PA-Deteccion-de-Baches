class GPSData {
  double latitude;
  double longitude;

  GPSData({required this.latitude, required this.longitude});

  @override
  String toString() {
    return 'GPS{latitude: $latitude, longitude: $longitude}';
  }

  List<double> get values => [latitude, longitude];
}
