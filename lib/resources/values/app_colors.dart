import 'package:flutter/material.dart';

abstract class AppColors {

  static const Color darkColor = Colors.black;
  static const Color lightColor = Colors.white;

  static const Map<int, Color> backgroundColorMap = {
    50: Color.fromRGBO(55, 31, 33, .1),
    100: Color.fromRGBO(55, 31, 33, .2),
    200: Color.fromRGBO(55, 31, 33, .3),
    300: Color.fromRGBO(55, 31, 33, .4),
    400: Color.fromRGBO(55, 31, 33, .5),
    500: Color.fromRGBO(55, 31, 33, .6),
    600: Color.fromRGBO(55, 31, 33, .7),
    700: Color.fromRGBO(55, 31, 33, .8),
    800: Color.fromRGBO(55, 31, 33, .9),
    900: Color.fromRGBO(55, 31, 33, 1),
  };

  static const backgroundColorInt = 0xFF371F21;
  static const Color backgroundColor = Color(backgroundColorInt);
  static const Color backgroundColorUnselected = Color(0x88371F21);
  static const Color backgroundColorBottomBar = Color(0xFFf4c862);
  static const MaterialColor backgroundMaterialColor = MaterialColor(backgroundColorInt, backgroundColorMap);

  static const Color lightTextColor = lightColor;
  static const Color darkTextColor = darkColor;
  static const Color shadowColor = darkColor;
  static const Color chartsSeparatorColor = lightColor;

  static const Color chartsCardColor = Colors.grey;

  static final Color transparentBlackCardColor = Colors.black.withAlpha(100);
  static final Color fabBackgroundColor = Colors.orange.withAlpha(120);

  static final cmcDark = const Color(0xFF3B748C); static const cmcDarkStringHex = '#3B748C';
  static final cmcLight = const Color(0xFFB7DAEF); static const cmcLightStringHex = '#B7DAEF';
  static final daDark = const Color(0xFF3A5C2A); static const daDarkStringHex = '#3A5C2A';
  static final daLight = const Color(0xFFCCEF85); static const daLightStringHex = '#CCEF85';
  static final hsDark = const Color(0xFF73442C); static const hsDarkStringHex = '#73442C';
  static final hsLight = const Color(0xFFE6936C); static const hsLightStringHex = '#E6936C';
  static final lohDark = const Color(0xFF646155); static const lohDarkStringHex = '#646155';
  static final lohLight = const Color(0xFFE8E3C8); static const lohLightStringHex = '#E8E3C8';
  static final momDark = const Color(0xFF513C2B); static const momDarkStringHex = '#513C2B';
  static final momLight = const Color(0xFFE6AE61); static const momLightStringHex = '#E6AE61';
  static final mDark = const Color(0xFF273675); static const mDarkStringHex = '#273675';
  static final mLight = const Color(0xFF99B1F9); static const mLightStringHex = '#99B1F9';
  static final mgsDark = const Color(0xFF875F04); static const mgsDarkStringHex = '#875F04';
  static final mgsLight = const Color(0xFFE6C976); static const mgsLightStringHex = '#E6C976';
  static final maDark = const Color(0xFF612231); static const maDarkStringHex = '#612231';
  static final maLight = const Color(0xFFEF989A); static const maLightStringHex = '#EF989A';
  static final wwwDark = const Color(0xFF13717E); static const wwwDarkStringHex = '#13717E';
  static final wwwLight = const Color(0xFF72F9F9); static const wwwLightStringHex = '#72F9F9';
  static final oDark = const Color(0xFF382463); static const oDarkStringHex = '#382463';
  static final oLight = const Color(0xFFA77CE8); static const oLightStringHex = '#A77CE8';

  static const Color lowThreatColor = Colors.grey;
  static const Color lowAltThreatColor = Colors.black;
  static const Color mediumThreatColor = Colors.white;
  static const Color highThreatColor = Colors.yellow;
  static const Color severeThreatColor = Colors.orange;
  static const Color emergencyThreatColor = Colors.red;

  static const Color tutorialColor = Colors.brown;
}