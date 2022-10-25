import 'package:deteccion_de_baches/src/pages/pothole_drop_down_button.dart';
import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:deteccion_de_baches/src/themes/my_style.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  List<String> items = ["pothole", "not pothole"];
  String? selectedItem = "pothole";

  @override
  void initState() {
    super.initState();
    fileNameController = TextEditingController();
  }

  callback(newSelectedItem) {
    setState(() {
      selectedItem = newSelectedItem;
    });
  }

  Widget cancelAButton() {
    return TextButton.icon(
        style: PotholeStyle.actionButtonDialogStyle,
        label: const Text("Cancel", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.cancel, color: PotholeColor.primary),
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
      style:PotholeStyle.actionButtonDialogStyle,
      icon: const Icon(Icons.check, color: PotholeColor.primary),
      label: const Text("Mark anomaly", style: TextStyle(color: Colors.white)),
      onPressed: () {
        
          String fullPath =
              "${widget.mainDirectory}/${widget.subdirectories[1]}";
          makeAppFolders(widget.mainDirectory, widget.subdirectories);
          // Verify if exist a previous file with this name
          String label = selectedItem as String;
          if (widget.position != null) {
            saveMarksToJson(fullPath, widget.position as Position, label);
          }
          Navigator.pop(context);
        },

        
      
    );
  }

// TextFormField(
//         controller: fileNameController,
//         decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'anomaly label',
//             focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 3, color: PotholeColor.primary)),
//             suffixIcon: Icon(Icons.label, color: PotholeColor.primary,)),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter a label name for the anomaly detected';
//           }
//           return null;
//         },
//       )

// SizedBox(
//             width: 200,
//             child: DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           BorderSide(width: 3, color: PotholeColor.primary)),
//                   iconColor: PotholeColor.primary),
//               value: selectedItem,
//               items: items
//                   .map((item) => DropdownMenuItem<String>(
//                       value: item,
//                       child: Text(item,
//                           style: TextStyle(fontSize: 16, color: Colors.white))))
//                   .toList(),
//               onChanged: (item) => setState(() {
//                 selectedItem = item;
//               }),
//             ))
  Widget markAnomalydDialog() {
    return AlertDialog(
      title: const Text('Anomaly selector'),
      content: PotholeDropDownButton(
        width: 200,
        selectedItem: selectedItem,
        items: items,
        callback: callback,
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
