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
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }
}
