import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme._();

  static const String fontFamily = 'BeVietnamPro';

  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 44,
      fontWeight: FontWeight.w700,
      height: 52 / 44,
      letterSpacing: -0.88, // -2% of 44
    ),

    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 40 / 32,
    ),

    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 28 / 22,
    ),

    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
    ),

    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
    ),

    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      letterSpacing: 0.5,
    ),
  );

  static const TextTheme darkTextTheme = lightTextTheme;
}
