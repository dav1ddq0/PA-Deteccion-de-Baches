import 'dart:convert';
import 'dart:io';
import 'package:deteccion_de_baches/src/utils/permissions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';

// Folders needed for data persistence in the Pothole application
Future<void> makeAppFolders(
    String mainDirectory, List<String> subdirectories) async {
  await createDirectory(mainDirectory);
  for (String subdirectory in subdirectories) {
    await createDirectory('$mainDirectory/$subdirectory');
  }
}

// Create an empty directory from a input filename given
Future<void> createDirectory(String dataPath) async {
  await grantStoragePermission();

  Directory path = Directory(dataPath);

  if (!(await path.exists())) {
    await path.create();
  }
}

// Delete a file from its name
Future<void> deleteFile(String filename) async {
  File file = File(filename);
  if (file.existsSync()) {
    await file.delete();
  }
}

// Check if a filename alreaddy exists
bool myfileAlreadyExists(filename) {
  return File("$filename").existsSync();
}

Future<void> clearTempPicker() async {
  await FilePicker.platform.clearTemporaryFiles();
}

// Pick a file using the  native file explorer of the device
Future<PlatformFile?> pickFile() async {
  // An utility method that will explicitly prune cached files from the picker
  await clearTempPicker();
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.any,
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    return file;
  } else {
    return null;
  }
}

Future<List<dynamic>> loadMarks(PlatformFile? file) async {
  if (file != null) {
    File jsonMarks = File(file.path as String);
    if (jsonMarks.existsSync()) {
      List<dynamic> jsonFileContent =
          json.decode(jsonMarks.readAsStringSync())['marks'];
      return jsonFileContent;
    } else {
      return [];
    }
  }
  return [];
}

Future<List<dynamic>> loadRecords(PlatformFile? file) async {
  if (file != null) {
    File jsonMarks = File(file.path as String);
    if (jsonMarks.existsSync()) {
      List<dynamic> jsonFileContent = json.decode(jsonMarks.readAsStringSync());
      List<dynamic> marks = [];
      for (var item in jsonFileContent) {
        marks.add({'position': item['gps'], 'label': item['label']});
      }
      return marks;
    } else {
      return [];
    }
  }
  return [];
}

Future<File> saveRecordToJson(String dataPath, List<dynamic> data,
    {String filename = 'record'}) async {
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
  final File jsonFile = File('$dataPath/$filename.json');

  if (jsonFile.existsSync()) {
    Map<String, dynamic> jsonFileContent =
        json.decode(jsonFile.readAsStringSync());

    jsonFileContent['records'] = data;
    jsonFileContent['time'] = time;
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));

    return jsonFile;
  } else {
    jsonFile.writeAsStringSync(json.encode({'records': data, 'time': time}));
    return jsonFile;
  }
}

Future<File> saveMarksToJson(
    String dataPath, Position position, String label) async {
  final File jsonFile = File('$dataPath/marks.json');
  final Map newMark = {
    'position': {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
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
