import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuple/tuple.dart';

import 'package:deteccion_de_baches/src/pages/accelerometer_data.dart';

class JData {
  late File jsonFile;
  late Directory dir;
  String fileName = "myjson.json";
  bool fileExists = false;
  late Map<String, int> fileContent;
  late String path;
  final String dataPath =
      '/storage/emulated/0/bump_data'; // path where json data is stored

  JData() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      this.dir = directory;
      jsonFile = File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      fileContent = {};
      if (fileExists) {
        fileContent = json.decode(jsonFile.readAsStringSync());
      } else {
        fileContent = {};
      }
    });
  }

  // Map<String, List> getJsonData(File file) {

  // }

  // Métodos para obtener lecturas de los senspores y realizar operaciones con esta información
  Future<void> _grantStoragePermissions() async {
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

  Future<File> saveToJson(List<AccelerometerData> records) async {
    await createBumpFolder();
    final File jsonFile = File('$dataPath/bumps.json');
    if (jsonFile.existsSync()) {}

    final Map<String, List<List<double>>> data =
        Map<String, List<List<double>>>();
    List<List<double>> toJsonRecords =
        data['accel'] = [for (AccelerometerData item in records) item.values];
    jsonFile.writeAsStringSync(json.encode(data));
    return jsonFile;
  }

  Future<File> createFile(Map<String, int> content) async {
    await _grantStoragePermissions();
    File file = File(dir.path + "/" + fileName);
    // file.copySync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
    return file;
  }

  Future<String> get localPath async {
    // Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    Directory? appDocumentsDirectory = await getExternalStorageDirectory();
    String? appDocumentsPath = appDocumentsDirectory?.path;
    String filePath = '$appDocumentsPath/demoTextFile.txt';
    return filePath;
  }

  Future<Directory> createBumpFolder() async {
    await _grantStoragePermissions();
    final path = Directory(dataPath);
    print(path);
    if (!(await path.exists())) {
      var res = await path.create();
      return res;
    }
    return path;
  }

  Future<File> get templocalFile async {
    await createBumpFolder();
    // final path = await localPath;
    final newfile = File('$dataPath/fif.txt');
    //Need copy some of info to test
    newfile.writeAsString('Bumps....');

    return newfile;
  }
}
