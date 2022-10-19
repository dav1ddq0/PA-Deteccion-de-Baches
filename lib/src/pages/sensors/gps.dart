import 'package:flutter/material.dart';

class GPSSensor extends StatefulWidget {
  String latitude;
  String longitude;
  GPSSensor({
    Key? key,
    required this.latitude,
    required this.longitude,
    }) : super(key: key);

  @override
  State<GPSSensor> createState() => _GPSSensorState();
}

class _GPSSensorState extends State<GPSSensor> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(10),

          child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.blue[200],size: 37),
                Text("GPS:", style: TextStyle(
                  color: Colors.blue[200],
                  fontSize: 18
                )),
              ],
            ),
            
            Column(
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children:[                  
                LatLngRowW(name: "Lat", value: widget.latitude),
                SizedBox(width:40),
                LatLngRowW(name: "Lng", value: widget.longitude)
                ],
                  )
                 
                ]

              )
            ,
        
      ],)
          
        
        
    );
  }
}

class LatLngRowW extends StatelessWidget {
  final String name;
  final String value;
  const LatLngRowW({required this.name, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$name:", style: TextStyle(
          color: Colors.blue[200],
          fontSize: 20
        ),),
        SizedBox(width:8),
        Text(value.toString(),style: TextStyle(
          color: Colors.blue[200],
          fontSize: 20
        ),)
      ],
    );
  }
}