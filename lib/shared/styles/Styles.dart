import 'package:chat_ai/shared/styles/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  fontFamily: 'Varela',
  colorScheme: ColorScheme.light(
    primary: lightPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0.0,
    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: secondColor,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: secondColor,
    clipBehavior: Clip.antiAlias,
  ),
);


ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: darkBackground,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  fontFamily: 'Varela',
  colorScheme: ColorScheme.dark(
    primary: darkPrimary,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkBackground,
    scrolledUnderElevation: 0.0,
    elevation: 0,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: darkBackground,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: firstColor,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: firstColor,
    clipBehavior: Clip.antiAlias,
  ),
);