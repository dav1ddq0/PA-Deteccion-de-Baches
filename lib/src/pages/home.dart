import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/recorder_button.dart';
import 'package:deteccion_de_baches/src/pages/stopwatch.dart';
import 'package:deteccion_de_baches/src/pages/save_data_widget.dart';

class HomeTab extends StatefulWidget {
  final bool scanning;
  HomeTab({required this.scanning, Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin{
  
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      child:Column(
        children: [
          Text(widget.scanning.toString()),
          SaveDataDialog()

        ]
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}