import 'package:flutter/material.dart';
import '../utils/saved_data.dart';
import '../utils/storage_utils.dart';

class SaveDataDialog extends StatefulWidget {
  SaveDataDialog({Key? key}) : super(key: key);

  @override
  State<SaveDataDialog> createState() => _SaveDataDialogState();
}

class _SaveDataDialogState extends State<SaveDataDialog> {
  final String mainDirectory =
      '/storage/emulated/0/Baches'; // path where json data is stored
  final List<String> subdirectories = ['sensors', 'mark_labels', 'exported'];
  late TextEditingController fileNameController;
  late JData collectedData;

  @override
  void initState() {
    super.initState();
    fileNameController = TextEditingController();
    collectedData = JData();
  }

  Widget cancelAButton() {
    return TextButton.icon(
        label: const Text("Cancel", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.cancel, color: Colors.red),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  SnackBar _emptyALabel() {
    const SnackBar _snackBar = SnackBar(
      backgroundColor: Colors.black,
      duration: Duration(seconds: 2),
      content: Text('Please enter a label for the anomaly detected',
          style: TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(left: 40.0, right: 40),
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
      margin: EdgeInsets.only(left: 40.0, right: 40),
    );
    return _snackBar;
  }

  Widget markAButton() {
    return TextButton.icon(
      icon: const Icon(Icons.check, color: Colors.green),
      label: const Text("Mark anomaly", style: TextStyle(color: Colors.white)),
      onPressed: () {
        String filename = fileNameController.text;
        if (filename == null || filename == "") {
          ScaffoldMessenger.of(context).showSnackBar(_emptyALabel());
        } else {
          String fullPath =
              "$mainDirectory/${subdirectories[2]}/$filename.json";
          makeAppFolders(mainDirectory, subdirectories);
          // Verify if exist a previous file with this name
          if (myfileAlreadyExists(fullPath)) {
            ScaffoldMessenger.of(context)
                .showSnackBar(_fileAlreadyExistsSB(filename));
          } else {
            // Exported  file to the exported folder
            collectedData.exportRecordData(
                '$mainDirectory/${subdirectories[2]}',
                filename,
                '$mainDirectory/${subdirectories[0]}');
          }
        }

        Navigator.pop(context);
      },
    );
  }

  Widget markAnomalydDialog() {
    return AlertDialog(
      title: const Text('Anomaly detected'),
      content: TextFormField(
        controller: fileNameController,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Choose a name for this anomaly',
            prefixIcon: Icon(Icons.label)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a label name for the anomaly detected';
          }
          return null;
        },
      ),
      actions: <Widget>[markAButton(), cancelAButton()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: const Text('Mark anomaly'),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return markAnomalydDialog();
              });
        });
  }
}
