import 'package:flutter/widgets.dart';

class SizeConfig {
  late MediaQueryData _mediaQueryData;
  late double screenWidth;
  late double screenHeight;
  late double blockSizeHorizontal;
  late double blockSizeVertical;

  late double _safeAreaHorizontal;
  late double _safeAreaVertical;
  late double safeBlockHorizontal;
  late double safeBlockVertical;

  SizeConfig(BuildContext context) {
	_mediaQueryData = MediaQuery.of(context);
	screenWidth = _mediaQueryData.size.width;
	screenHeight = _mediaQueryData.size.height;
	blockSizeHorizontal = screenWidth / 100;
	blockSizeVertical = screenHeight / 100;

	_safeAreaHorizontal = _mediaQueryData.padding.left + 
	_mediaQueryData.padding.right;
	_safeAreaVertical = _mediaQueryData.padding.top +
	_mediaQueryData.padding.bottom;
	safeBlockHorizontal = (screenWidth -
	_safeAreaHorizontal) / 100;
	safeBlockVertical = (screenHeight -
	_safeAreaVertical) / 100;
  }
}
