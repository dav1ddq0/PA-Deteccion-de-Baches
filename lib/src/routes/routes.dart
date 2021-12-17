import 'package:flutter/material.dart';

import 'package:deteccion_de_baches/src/pages/social_media_page.dart';
import 'package:deteccion_de_baches/src/pages/home_page.dart';
import 'package:deteccion_de_baches/src/pages/info_page.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => MyHomePage(title: 'Bump Record2'),
    '/info': (BuildContext context) => InfoPage(),
    '/socialmedia': (BuildContext context) => SocialMediaPage()
  };
}
