import 'package:flutter/material.dart';

/// Contains all the fonts used in the app.
class AppFonts {
  static final double _height = 1.5;

  /// The text themes of the app.
  static TextTheme get textTheme => TextTheme(
        displayLarge: TextStyle(
          fontSize: 70,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontSize: 55,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontSize: 48,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontSize: 40,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          height: _height,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: _height,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: _height,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          height: _height,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          height: _height,
          fontWeight: FontWeight.normal,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          height: _height,
          fontWeight: FontWeight.normal,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          height: _height,
          fontWeight: FontWeight.normal,
        ),
      );
}
