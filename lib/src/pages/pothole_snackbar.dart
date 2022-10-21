import 'package:flutter/material.dart';

import '../themes/color.dart';
import '../themes/my_style.dart';

SnackBar primaryPotholeSnackBar(String info) {
  return SnackBar(
    backgroundColor: PotholeColor.primary,
    duration: const Duration(seconds: 2),
    content: Text(info, style: const TextStyle(color: PotholeColor.darkText)),
    behavior: SnackBarBehavior.floating,
    margin: PotholeStyle.snackBarMargin,
  );
}
