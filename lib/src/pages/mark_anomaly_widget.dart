import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:deteccion_de_baches/src/themes/my_style.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/saved_data.dart';
import '../utils/storage_utils.dart';

class MarkAnomaly extends StatefulWidget {
  final String mainDirectory;
  final List<String> subdirectories;
  final Position? position; // GPS location of the anomaly

  const MarkAnomaly(
      {Key? key,
      required this.mainDirectory,
      required this.subdirectories,
      required this.position})
      : super(key: key);

  @override
  State<MarkAnomaly> createState() => _MarkAnomalyState();
}

class _MarkAnomalyState extends State<MarkAnomaly> {
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
      backgroundColor: PotholeColor.primary,
      duration: Duration(seconds: 2),
      content: Text('Please enter a label for the anomaly detected',
          style:PotholeStyle.snackBarTextStyle),
      behavior: SnackBarBehavior.floating,
      margin: PotholeStyle.snackBarMargin,
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
              "${widget.mainDirectory}/${widget.subdirectories[1]}";
          makeAppFolders(widget.mainDirectory, widget.subdirectories);
          // Verify if exist a previous file with this name
          String label = fileNameController.text.toLowerCase();
          if (widget.position != null) {
            collectedData.saveMarksToJson(fullPath, widget.position as Position, label);
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
            hintText: 'anomaly label',
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
        child: const Text('Mark anomaly', style: TextStyle(color: PotholeColor.darkText),),
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15),
            textStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return markAnomalydDialog();
              });
        });
  }
}
