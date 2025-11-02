// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    fontFamily: 'Poppins', // fallback for every widget
    scaffoldBackgroundColor: const Color(0xFFFFF8F0),

    // ---- TextTheme (replaces every Material default) -----------------------
    textTheme: TextTheme(
      displayLarge: HomifyTypography.title1,
      displayMedium: HomifyTypography.title2,
      displaySmall: HomifyTypography.title3,

      headlineLarge: HomifyTypography.heading1,
      headlineMedium: HomifyTypography.heading2,
      headlineSmall: HomifyTypography.heading3,
      titleLarge: HomifyTypography.heading4,
      titleMedium: HomifyTypography.heading5,
      titleSmall: HomifyTypography.heading6,

      labelLarge: HomifyTypography.label1,
      labelMedium: HomifyTypography.label2,
      labelSmall: HomifyTypography.label3,

      bodyLarge: HomifyTypography.body1,
      bodyMedium: HomifyTypography.body2,
      bodySmall: HomifyTypography.body3,
    ),

    // ---- InputDecoration (TextField labels, hints, helpers) ---------------
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: HomifyTypography.label1,
      hintStyle: HomifyTypography.body3.copyWith(color: Colors.grey),
      helperStyle: HomifyTypography.label3,
      // keep your border colors
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF32190D), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF32190D), width: 2),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      // cursorColor: const Color(0xFF32190D),
    ),

    // ---- Buttons -----------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: HomifyTypography.label1,
        minimumSize: const Size(double.infinity, 44),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: HomifyTypography.label1,
        minimumSize: const Size(double.infinity, 44),
      ),
    ),
  );
}
