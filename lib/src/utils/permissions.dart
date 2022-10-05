import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> grantLocationPermission() async {
  // Test if location services are enabled.
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    await Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
}

Future<void> grantStoragePermissions() async {
  var storageStatus = await Permission.storage.status;

  if (!storageStatus.isGranted) {
    await Permission.storage.request();
  }

  // Get device info
  var androidInfo = await DeviceInfoPlugin().androidInfo;
  // Get device androids version
  var release = int.parse(androidInfo.version.release.toString().split('.')[0]);

  // For Andorid 10 and above
  if (release >= 10) {
    var mediaLocationStatus = await Permission.accessMediaLocation.status;
    if (!mediaLocationStatus.isGranted) {
      await Permission.accessMediaLocation.request();
    }
  }

  //For Android 11 and above
  if (release >= 11) {
    var externalStorageStatus = await Permission.manageExternalStorage.status;
    if (!externalStorageStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }
}

//Folders needed for data persistence in the application
Future<void> makeAppFolders(
    String mainDirectory, List<String> subdirectories) async {
  await createDirectory(mainDirectory);
  for (String subdirectory in subdirectories) {
    await createDirectory('$mainDirectory/$subdirectory');
  }
}

Future<void> createDirectory(String dataPath) async {
  await grantStoragePermissions();

  Directory path = Directory(dataPath);

  if (!(await path.exists())) {
    await path.create();
  }
}
