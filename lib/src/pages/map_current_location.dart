import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:deteccion_de_baches/src/pages/pothole_snackbar.dart';

class MapCLocation extends StatefulWidget {
  final Position? currentLocation;
  MapCLocation({required this.currentLocation, Key? key}) : super(key: key);

  @override
  State<MapCLocation> createState() => _MapCLocationState();
}

class _MapCLocationState extends State<MapCLocation>
    with AutomaticKeepAliveClientMixin {
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

  Widget centerAgain() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15)),
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.gps_fixed, color: PotholeColor.darkText));
  }

  Widget backMain() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: PotholeColor.primary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(15)),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.keyboard_arrow_left,
            color: PotholeColor.darkText));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Map-Current Position",
                style: TextStyle(color: PotholeColor.primary))),
        body: Container(
            child:
                MapPage(currentLocation: widget.currentLocation, zoom: zoom)),
        floatingActionButton: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
            child: Row(
              children: [
                backMain(),
                const SizedBox(width: 20),
                zoomPlus(),
                const SizedBox(width: 8),
                zoomMinus(),
                const SizedBox(width: 20),
                centerAgain()
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;
}

class MapPage extends StatelessWidget {
  late double zoom;
  Position? currentLocation;

  MapPage({required this.currentLocation, required double zoom, Key? key})
      : super(key: key) {
    this.zoom = zoom;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      key: UniqueKey(),
      options: MapOptions(
        center: LatLng(currentLocation?.latitude as double,
            currentLocation?.longitude as double),
        zoom: zoom,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(
          markers: [
            Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(currentLocation?.latitude as double,
                    currentLocation?.longitude as double),
                builder: (ctx) => Container(
                      child: Icon(Icons.location_on,
                          color: Color.fromARGB(255, 15, 149, 211), size: 35),
                    ))
          ],
        ),
      ],
    );
  }
}
