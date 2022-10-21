import 'dart:convert';
import 'dart:io';
import 'package:deteccion_de_baches/src/utils/permissions.dart';
import 'package:file_picker/file_picker.dart';

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

// Check if a filename alreaddy exists
bool myfileAlreadyExists(filename) {
  return File("$filename").existsSync();
}

Future<PlatformFile?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null) {
    //File file = File(result.files.single.path.toString());
    PlatformFile file = result.files.first;

    print(file.name);
    print(file.bytes);
    print(file.size);
    print(file.extension);
    print(file.path);
    return file;
  } else {
    return null;
    // User canceled the picker
  }
}

Future<List<Map>> loadMarks() async {
  PlatformFile? file = await pickFile();

  if (file != null) {
    File jsonMarks = File(file.path as String);
    if (jsonMarks.existsSync()) {
      List<Map<dynamic,dynamic>> jsonFileContent =
          json.decode(jsonMarks.readAsStringSync());
      return jsonFileContent;
    }
    else{
      return [];
    }
  }
  return [];
}

