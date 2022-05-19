import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
  File createFile(Map<String, int> content) {
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

  Future<File> get templocalFile async {
    // final path = await localPath;
    final newfile = File('$dataPath/fif.txt');
    //Need copy some of info to test
    newfile.writeAsString('Bumps....');

    return newfile;
  }

  Future<void> createBumpFolder() async {
    final path = Directory(dataPath);
    print(path);
    if (!(await path.exists())) {
      path.create();
    }
  }
}
