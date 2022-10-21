import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/themes/my_style.dart';
import 'package:deteccion_de_baches/src/themes/color.dart';
import '../utils/permissions.dart';
import '../utils/saved_data.dart';
import '../utils/storage_utils.dart';

class SaveDataDialog extends StatefulWidget {
  final int time;
  final bool scanning;
  final String mainDirectory;
  final List<String> subdirectories;
  const SaveDataDialog(
      {required this.time,
      required this.scanning,
      Key? key,
      required this.mainDirectory,
      required this.subdirectories})
      : super(key: key);

  @override
  State<SaveDataDialog> createState() => _SaveDataDialogState();
}

class _SaveDataDialogState extends State<SaveDataDialog> {
  late TextEditingController fileNameController;
  late JData collectedData;

  @override
  void initState() {
    super.initState();
    fileNameController = TextEditingController();
    collectedData = JData();
  }

  Widget cancelRButton() {
    return TextButton.icon(
        label: const Text("Cancel", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.cancel, color: Colors.red),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  SnackBar _emptyRecordNameSB() {
    const SnackBar _snackBar = SnackBar(
      backgroundColor: PotholeColor.primary,
      duration: Duration(seconds: 2),
      content: Text('Please enter a record name',
          style: TextStyle(color: PotholeColor.darkText)),
      behavior: SnackBarBehavior.floating,
      margin: PotholeStyle.snackBarMargin,
    );
    return _snackBar;
  }

  SnackBar _fileAlreadyExistsSB(String filename) {
    SnackBar _snackBar = SnackBar(
      backgroundColor: Colors.black,
      duration: const Duration(seconds: 2),
      content: Text(
          "The file $filename.json already exists. Please choose another name",
          style: TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      margin: PotholeStyle.snackBarMargin,
    );
    return _snackBar;
  }

  SnackBar _stillScanning() {
     SnackBar _snackBar = SnackBar(
      backgroundColor: PotholeColor.primary,
      duration: const Duration(seconds: 2),
      content: Text(
          "it is still scanning scanning. Please stop scanning first.",
          style: TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      margin: PotholeStyle.snackBarMargin,
    );
    return _snackBar;
  }

  Widget saveRButton() {
    return TextButton.icon(
      icon: const Icon(Icons.check, color: Colors.green),
      label: const Text("Save Record", style: TextStyle(color: Colors.white)),
      onPressed: () {
        String filename = fileNameController.text;
        if (filename == null || filename == "") {
          ScaffoldMessenger.of(context).showSnackBar(_emptyRecordNameSB());
        } else {
          String fullPath =
              "${widget.mainDirectory}/${widget.subdirectories[2]}/$filename.json";
          makeAppFolders(widget.mainDirectory, widget.subdirectories);
          // Verify if exist a previous file with this name
          if (myfileAlreadyExists(fullPath)) {
            ScaffoldMessenger.of(context)
                .showSnackBar(_fileAlreadyExistsSB(filename));
          } else {
            // Exported  file to the exported folder
            collectedData.exportRecordData(
                '${widget.mainDirectory}/${widget.subdirectories[2]}',
                filename,
                '${widget.mainDirectory}/${widget.subdirectories[0]}');
          }
        }

        Navigator.pop(context);
      },
    );
  }

  Widget exportRecordDialog() {
    return AlertDialog(
      title: const Text('Save record'),
      content: TextFormField(
        controller: fileNameController,
        decoration: const InputDecoration(
            iconColor: PotholeColor.primary,
            border: OutlineInputBorder(),
            hintText: 'Choose a name for this record',
            prefixIcon: Icon(Icons.file_copy)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a record name';
          }
          return null;
        },
      ),
      actions: <Widget>[saveRButton(), cancelRButton()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: const Text('Save record as', style: TextStyle(color: PotholeColor.darkText)),
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15),
            textStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        onPressed: () {
          if (widget.scanning) {
            ScaffoldMessenger.of(context)
                .showSnackBar(_stillScanning());
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return exportRecordDialog();
                });
          }
        });
  }
}
