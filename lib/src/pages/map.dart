import 'dart:convert';
import 'dart:io';

import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:deteccion_de_baches/src/themes/my_style.dart';
import 'package:deteccion_de_baches/src/utils/storage_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import 'package:deteccion_de_baches/src/pages/pothole_snackbar.dart';

class MapTab extends StatefulWidget {
  MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin {
  List<dynamic> marks = [];
  List<String> items = ["Marks", "Records"];
  String? selectedItem = "Marks";

  double zoom = 14.0;

  SnackBar _maxZoomReach() {
    SnackBar _snackBar =
        primaryPotholeSnackBar("The maximum zoom has been reached.");
    return _snackBar;
  }

  SnackBar _minZoomReach() {
    SnackBar _snackBar =
        primaryPotholeSnackBar("The minimum zoom has been reached.");
    return _snackBar;
  }

  Widget zoomPlus() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15)),
        onPressed: () {
          setState(() {
            if (zoom + 0.5 > 18) {
              ScaffoldMessenger.of(context).showSnackBar(_maxZoomReach());
            } else {
              zoom += 0.5;
            }
            print(zoom);
          });
        },
        child: const Icon(
          Icons.zoom_in,
          color: PotholeColor.darkText,
        ));
  }

  Widget zoomMinus() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15)),
        onPressed: () {
          setState(() {
            print(zoom);
            if (zoom - 0.5 < 6) {
              ScaffoldMessenger.of(context).showSnackBar(_minZoomReach());
            } else {
              zoom -= 0.5;
            }
          });
        },
        child: Icon(Icons.zoom_out, color: PotholeColor.darkText));
  }

  Widget okButton() {
    return TextButton.icon(
        style: PotholeStyle.actionButtonDialogStyle,
        icon: const Icon(Icons.check, color: PotholeColor.primary),
        label: const Text("OK", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          PlatformFile? file = await pickFile();
          if (file != null) {
            if (file.extension != 'json') {
              ScaffoldMessenger.of(context).showSnackBar(primaryPotholeSnackBar(
                  "Invalid file. A JSON file is required."));
            } else {
              List<dynamic> jsonMarks = [];
              if (selectedItem == "Marks") {
                jsonMarks = await loadMarks(file);
              } else {
                jsonMarks = await loadRecords(file);
              }

              setState(() {
                if (jsonMarks.isNotEmpty) {
                  marks = jsonMarks;
                }
              });
            }
          }
          Navigator.pop(context);
        });
  }

  Widget dataSelectorDialog() {
    return AlertDialog(
        title:
            const Text('Map Selector ', style: TextStyle(color: Colors.white)),
        backgroundColor: PotholeColor.darkText,
        content: SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(width: 3, color: PotholeColor.primary)),
                  iconColor: PotholeColor.primary),
              value: selectedItem,
              items: items
                  .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item,
                          style: TextStyle(fontSize: 16, color: Colors.white))))
                  .toList(),
              onChanged: (item) => setState(() {
                selectedItem = item;
              }),
            )),
        actions: <Widget>[okButton()]);
  }

  Widget addMarks() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15)),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return dataSelectorDialog();
              });
        },
        child: Icon(Icons.add, color: PotholeColor.darkText));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: MapPage(marks: marks, zoom: zoom)),
        floatingActionButton: Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(top: 20, right: 20, left: 20),
            child: Row(
              children: [
                addMarks(),
                const SizedBox(width: 20),
                zoomPlus(),
                const SizedBox(width: 8),
                zoomMinus(),
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;
}

class MapPage extends StatelessWidget {
  late List<Marker> markers = <Marker>[];
  late double zoom;

  MapPage({required List<dynamic> marks, required double zoom, Key? key})
      : super(key: key) {
    for (var mark in marks) {
      // print(mark);
      dynamic position = mark['position'];
      markers.add(Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(position['latitude'], position['longitude']),
          builder: (ctx) => Container(
                child: Icon(Icons.location_on, color: PotholeColor.primary),
              )));
    }
    this.zoom = zoom;
  }

  @override
  Widget build(BuildContext context) {
    print(zoom);
    print(markers);
    return FlutterMap(
      key: UniqueKey(),
      options: MapOptions(
        center:
            markers.isEmpty ? LatLng(23.13329, -82.36698) : markers[0].point,
        //LatLng(23.13329, -82.36698),
        zoom: zoom,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(
          markers: markers,
        ),
      ],
    );
  }
}
