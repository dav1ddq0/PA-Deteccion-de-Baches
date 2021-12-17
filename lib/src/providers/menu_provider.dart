import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/services.dart' show rootBundle;

class _MenuProvider {
  List<dynamic> opts = [];

  _MenuProvider() {
    // loadData();
  }

  Future<List<dynamic>> loadData() async {
    final ans = await rootBundle.loadString('data/menu-opts.json');

    Map dataMap = json.decode(ans);
    opts = dataMap['routes'];

    return opts;
  }
}

final menu_provider = new _MenuProvider();
