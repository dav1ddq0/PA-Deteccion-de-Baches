import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapTab extends StatefulWidget {
  MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin{
  List<List<double>> points  = [[23.13369, -82.36078]];
  double zoom = 14.0;
  @override
  Widget build(BuildContext context) {
    print(points);
    return Scaffold(
      body:Container(
        child:MapPage(points:points, zoom: zoom)
      ),
      floatingActionButton: Container(
        alignment: Alignment.topRight,
        padding: EdgeInsets.only(top:20,right: 20, left: 20),
        child: Row(children: [
          ElevatedButton(
          onPressed: () {
            setState(() {
              // final result = await FilePicker.platform.pickFiles();
              points.addAll([[23.13256, -82.36062],[23.13102, -82.36181]]);
            });
          },
          child: Icon(Icons.add)
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              zoom += 0.5;
              // if (points.isNotEmpty){
              //   points.removeLast();
              // }
              
              
            });
          },
          child: Icon(Icons.zoom_in)
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (zoom <= 1){
                zoom = 1;
              }
              else{
                zoom -= 0.5;
              }
              
              
            });
          },
          child: Icon(Icons.zoom_out)
        ),
        ],)
    )
    
    );
  }

  @override
  bool get wantKeepAlive => true;
}



class MapPage extends StatelessWidget {
  
  late List<Marker> markers = <Marker>[];
  late double zoom ;
  
  MapPage({required List<List<double>> points, required double zoom,  Key? key}) : super(key: key){
    for (var point in points) {
      markers.add(
        Marker(
            width: 80.0,
            height: 80.0,
            point:  LatLng(point[0], point[1]),
            builder: (ctx) =>
              Container(
                child: Icon(Icons.location_on, color: Colors.redAccent),
            )
      )
      );
    }
    this.zoom = zoom;

  }

  @override
  Widget build(BuildContext context) {
  print(zoom);
  print(markers);  
  return  FlutterMap(
    key: UniqueKey(),
    options:  MapOptions(
      center:  LatLng(23.13329, -82.36698),
      zoom: zoom,
    ),
    layers: [
       TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c']
      ),
       MarkerLayerOptions(
        markers: markers,
      ),
    ],
  );
}
}

