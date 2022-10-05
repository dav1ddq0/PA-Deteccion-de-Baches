import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return  FlutterMap(
    options:  MapOptions(
      center:  LatLng(23.1368, -82.3815),
      zoom: 13.0,
    ),
    layers: [
       TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c']
      ),
       MarkerLayerOptions(
        markers: [
           Marker(
            width: 80.0,
            height: 80.0,
            point:  LatLng(23.1368, -82.3815),
            builder: (ctx) =>
              Container(
                child: FlutterLogo(),
            ),
          ),
        ],
      ),
    ],
  );
}
}
