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

  Widget addMarks() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15)),
        onPressed: () async {
          List<dynamic> jsonMarks = await loadMarks();
          setState(() {
             if (jsonMarks.isNotEmpty) {
              marks = jsonMarks;
             }
            // final result = await FilePicker.platform.pickFiles();
            // marks.add({
            //   'position': [23.13256, -82.36062],
            //   'label': "prueba"
            // });
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
      print(mark);
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
