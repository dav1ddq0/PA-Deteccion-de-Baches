import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> grantStoragePermissions() async {
  var storageStatus = await Permission.storage.status;

  if (!storageStatus.isGranted) {
	await Permission.storage.request();
  }

  // Get device info
  var androidInfo = await DeviceInfoPlugin().androidInfo;
  // Get device androids version
  var release =
	  int.parse(androidInfo.version.release.toString().split('.')[0]);

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

Future<void> createBumpDirectories(String dataPath) async {
  await grantStoragePermissions();

  final path = Directory(dataPath);
  final Directory rawDataPath = Directory(dataPath + '/data');
  final Directory marksPath = Directory(dataPath +  '/marks');

  if (!(await path.exists())) {
	await path.create();
  }

  if (!(await rawDataPath.exists())) {
	await rawDataPath.create();
  }

  if (!(await marksPath.exists())) {
	await marksPath.create();
  }
}
