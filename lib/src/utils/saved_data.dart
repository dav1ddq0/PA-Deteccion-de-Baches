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

  Future<File> saveToJson(String dataPath, List<AccelerometerData> accelRecords,
      List<GyroscopeData> gyroRecords, List<Position?> gpsRecords) async {
    final File jsonFile = File('$dataPath/bumps.json');
    Map<String, dynamic> mapRecords = {
      'accelerometer': [for (AccelerometerData item in accelRecords) item.values],
      'gyroscope': [for (GyroscopeData item in gyroRecords) item.values],
      'gps': [
        for (Position? item in gpsRecords) {
            'latitude': item?.latitude,
            'longitude': item?.longitude,
        }
      ]
    };

    if (jsonFile.existsSync()) {
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent['record${jsonFileContent.length}'] = mapRecords;
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      return jsonFile;
    } else {
      final Map<String, Map<String, dynamic>> data = {'record1': mapRecords};
      jsonFile.writeAsStringSync(json.encode(data));
      return jsonFile;
    }
  }

  Future<File> saveToJson2(String dataPath, Position position) async {
    final File jsonFile = File('$dataPath/marks.json');

    if (jsonFile.existsSync()) {
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      jsonFileContent['marks']?.add({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      return jsonFile;
    } else {
      List<dynamic> mark = [
        {
          'latitude': position.latitude,
          'longitude': position.longitude,
        }
      ];
      final Map<String, List<dynamic>> data = {'marks': mark};
      jsonFile.writeAsStringSync(json.encode(data));
      return jsonFile;
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


  /* Future<File> get templocalFile async { */
  /*   await createBumpFolder(); */
  /*   // final path = await localPath; */
  /*   final newfile = File('$dataPath/fif.txt'); */
  /*   //Need copy some of info to test */
  /*   newfile.writeAsString('Bumps....'); */

  /*   return newfile; */
  /* } */
}
