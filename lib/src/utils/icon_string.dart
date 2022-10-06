import 'package:flutter/material.dart';

final _icons = <String, IconData>{
  'map': Icons.map,
  'info': Icons.info,
  'social': Icons.connected_tv_outlined
};

Icon getIcon(String id) => Icon(_icons[id]);