

import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/themes/color.dart';

final myThemeDark = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    elevation: 0.0,
  ),
  scaffoldBackgroundColor: Color.fromARGB(255, 44, 47, 53),
  dialogBackgroundColor: Color(0xff121212),
  focusColor: PotholeColor.primary,
  accentColor: PotholeColor.primary,
  buttonColor:  PotholeColor.primary,
);