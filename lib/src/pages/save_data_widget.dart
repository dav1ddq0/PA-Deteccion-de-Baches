import 'package:flutter/material.dart';

class SaveDataDialog extends StatefulWidget {
  SaveDataDialog({Key? key}) : super(key: key);

  @override
  State<SaveDataDialog> createState() => _SaveDataDialogState();
}

class _SaveDataDialogState extends State<SaveDataDialog> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: const Text('Save data as'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Name your record'),
                content: TextField(
                  // controller: fileNameController,
                  decoration: const InputDecoration(
                      hintText: "Choose a name for this file"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    // style: ButtonStyle(
                    //     shape:
                    //         MaterialStateProperty.all<RoundedRectangleBorder>(
                    //             RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(18.0),
                    //                 side: BorderSide(
                    //                     color: Color.fromARGB(
                    //                         255, 128, 180, 223)))),
                    //     backgroundColor: MaterialStateProperty.all<Color>(
                    //         Color.fromARGB(255, 226, 91, 38)),
                    // )
                  ),
                  TextButton(
                    child: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      // filename = fileNameController.text;
                      // makeAppFolders(mainDirectory, subdirectories);
                      // collectedData.exportData(
                      //     '$mainDirectory/${subdirectories[2]}',
                      //     filename,
                      //     '$mainDirectory/${subdirectories[0]}');

                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}
