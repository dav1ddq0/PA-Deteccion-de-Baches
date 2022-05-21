import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

import 'package:tuple/tuple.dart';

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
    var mediaLocationStatus = await Permission.accessMediaLocation.status;
    var externalStorageStatus = await Permission.manageExternalStorage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    if (!mediaLocationStatus.isGranted) {
      await Permission.accessMediaLocation.request();
    }

    if (!externalStorageStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  Future<File> saveToJson(List<Tuple3<double, double, double>> records) async {
    await createBumpFolder();
    final File jsonFile = File('$dataPath/bumps.json');
    if (jsonFile.existsSync()) {}
    final Map<String, List<Tuple3>> data =
        Map<String, List<Tuple3<double, double, double>>>();
    data['accel'] = records;
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

  Future<void> createBumpFolder() async {
    await _grantStoragePermissions();
    final path = Directory(dataPath);
    print(path);
    if (!(await path.exists())) {
      path.create();
    }
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
