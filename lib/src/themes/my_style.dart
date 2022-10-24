import 'package:flutter/material.dart';
import 'package:deteccion_de_baches/src/themes/color.dart';

class PotholeStyle {
  static const EdgeInsetsGeometry snackBarMargin =
      EdgeInsets.only(left: 40.0, right: 40, bottom: 20);
  static const TextStyle snackBarTextStyle =
      TextStyle(color: PotholeColor.darkText, fontWeight: FontWeight.bold);
  static ButtonStyle actionButtonDialogStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side:
                  const BorderSide(color: PotholeColor.primary, width: 2.2))));
}
