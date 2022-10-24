import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

import 'package:deteccion_de_baches/src/utils/accelerometer_data.dart';
import 'package:deteccion_de_baches/src/utils/gyroscope_data.dart';

class JData {
  late File jsonFile;
  late Directory dir;
  String fileName = "myjson.json";
  bool fileExists = false;
  late Map<String, int> fileContent;
  late String path;

  JData() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
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

  Future<File> saveRecordToJson(String dataPath, List<dynamic> data,
      {String filename = 'record'}) async {
    print('$dataPath/$filename.json');
    final File jsonFile = File('$dataPath/$filename.json');

    if (jsonFile.existsSync()) {
      List<dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());

      jsonFileContent.addAll(data);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      return jsonFile;
    } else {
      jsonFile.writeAsStringSync(json.encode(data));
      return jsonFile;
    }
  }

  Future<File> exportRecordToJson(
      String dataPath, List<dynamic> data, String filename, int time) async {
    print('$dataPath/$filename.json');
    final File jsonFile = File('$dataPath/$filename.json');

    if (jsonFile.existsSync()) {
      Map<String,dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      
      jsonFileContent['records'] = data;
      jsonFileContent['time'] = time;
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));

      return jsonFile;
    } else {
      jsonFile.writeAsStringSync(json.encode({
        'records': data,
        'time': time
      }));
      return jsonFile;
    }
  }

  Future<File> saveMarksToJson(
      String dataPath, Position position, String label) async {
    final File jsonFile = File('$dataPath/marks.json');
    final Map newMark = {
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude
      },
      'label': label,
    };

    if (jsonFile.existsSync()) {
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      jsonFileContent['marks']?.add(newMark);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      return jsonFile;
    } else {
      List<dynamic> mark = [
        newMark,
      ];
      final Map<String, List<dynamic>> data = {'marks': mark};
      jsonFile.writeAsStringSync(json.encode(data));
      return jsonFile;
    }
  }

  Future<void> exportRecordData(
      String dataPath, String filename, String tempFilePath, int time) async {
    final File jsonFile = File('$tempFilePath/record.json');
    if (jsonFile.existsSync()) {
      List<dynamic> jsonRecords = json.decode(jsonFile.readAsStringSync());

      exportRecordToJson(dataPath, jsonRecords, filename, time);
    }
  }

  Future<File> createFile(Map<String, int> content) async {
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

  Future<void> deleteFile(String filename) async {
    File file = File(filename);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /* Future<File> get templocalFile async { */
  /*   await createBumpFolder(); */
  /*   // final path = await localPath; */
  /*   final newfile = File('$dataPath/fif.txt'); */
  /*   //Need copy some of info to test */
  /*   newfile.writeAsString('Bumps....'); */

  /*   return newfile; */
  /* } */
}
