import 'dart:io';
import 'package:deteccion_de_baches/src/utils/permissions.dart';

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
bool myfileAlreadyExists(filename){
  return File("$filename").existsSync(); 
}
