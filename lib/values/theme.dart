import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  primaryColor: Color(0xff212121),
  primaryColorLight: Color(0xff9e9e9e),
  primaryColorDark: Color(0xff000000),
  accentColor: Color(0xffff5722),
  scaffoldBackgroundColor: Color(0xff303030),
  dividerColor: Color(0x1fffffff),
  disabledColor: Color(0x62ffffff),
  textSelectionColor: Color(0xffff9800),
  backgroundColor: Color(0xff616161),
  dialogBackgroundColor: Color(0xff424242),
  hintColor: Color(0x80ffffff),
  errorColor: Color(0xffea2f2f),
);

final darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  backgroundColor: const Color(0xFF212121),
  accentColor: Colors.white,
  accentIconTheme: IconThemeData(color: Colors.black),
  dividerColor: Colors.black12,
);

final lightTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.white,
  brightness: Brightness.light,
  backgroundColor: const Color(0xFFE5E5E5),
  accentColor: Colors.black,
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.white54,
);

final appTheme = ThemeData(
  primarySwatch: MaterialColor(4282532418, {
    50: Color(0xfff2f2f2),
    100: Color(0xffe6e6e6),
    200: Color(0xffcccccc),
    300: Color(0xffb3b3b3),
    400: Color(0xff999999),
    500: Color(0xff808080),
    600: Color(0xff666666),
    700: Color(0xff4d4d4d),
    800: Color(0xff333333),
    900: Color(0xff191919)
  }),
  primaryColor: Color(0xFF424242),
  fontFamily: 'Arial',
  scaffoldBackgroundColor: Color(0xff303030),
  primaryColorLight: Color(0xffe6e6e6),
  brightness: Brightness.dark,
  accentColor: Color(0xFF66BB6A),
  accentColorBrightness: Brightness.dark,
  appBarTheme: AppBarTheme(
      color: Color(0xFF616161),
      textTheme: TextTheme(
          title: TextStyle(
              fontSize: 32, fontFamily: 'Arial', fontWeight: FontWeight.w700))),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Color(0xff303030),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Color(0xFF66BB6A),
    unselectedLabelColor: Color(0xFF53BB58),
    labelStyle: TextStyle(
      fontSize: 22.0,
    ),
    unselectedLabelStyle: TextStyle(fontSize: 18.0),
  ),
);
