import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/themes/my_style.dart';
import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:deteccion_de_baches/src/pages/pothole_snackbar.dart';
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
        style: PotholeStyle.actionButtonDialogStyle,
        label: const Text("Cancel",
            style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.cancel, color: PotholeColor.primary),
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
    SnackBar _snackBar = primaryPotholeSnackBar("The file $filename.json already exists. Please choose another name");
    return _snackBar;
  }

  SnackBar _stillScanning() {
    SnackBar _snackBar = primaryPotholeSnackBar(
        "it is still scanning scanning. Please stop scanning first.");
    return _snackBar;
  }

  Widget saveRButton() {
    return TextButton.icon(
      style: PotholeStyle.actionButtonDialogStyle,
      icon: const Icon(Icons.check, color: PotholeColor.primary),
      label: const Text("Save Record",
          style: TextStyle(color: Colors.white)),
      // style: ButtonStyle(
      //   foregroundColor: MaterialStateProperty PotholeColor.primary
      // ),
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
      title: const Text(
        'Save record',
        style: TextStyle(color: PotholeColor.primary)
      ),
      backgroundColor: PotholeColor.darkText,
      content: TextFormField(
        cursorColor: PotholeColor.primary,
           
                   
        controller: fileNameController,
        decoration: const InputDecoration(
          iconColor: PotholeColor.darkText,
          border:  OutlineInputBorder(borderSide: BorderSide(width: 3, color: PotholeColor.primary)),
          // enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 3, color: PotholeColor.primary)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 3, color: PotholeColor.primary)),
          hintText: 'Choose a name for this record',
          hintStyle: TextStyle(color: Colors.white, fontSize: 10),
          suffixIcon: Icon(Icons.file_copy,color: PotholeColor.primary)
        ),
        style: TextStyle(color: Colors.white),
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
        child: const Text('Save record as',
            style: TextStyle(color: PotholeColor.darkText)),
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15),
            textStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        onPressed: () {
          if (widget.scanning) {
            ScaffoldMessenger.of(context).showSnackBar(_stillScanning());
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
