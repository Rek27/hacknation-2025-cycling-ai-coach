import 'package:flutter/material.dart';
import 'package:hackathon/themes/app_colors.dart';
import 'package:hackathon/themes/app_fonts.dart';
import 'package:hackathon/themes/app_widget_themes.dart';

/// Holds the main themes of the app.
class AppThemes {
  /// The light themes of the app.
  static ThemeData get light =>
      _buildTheme(AppColors.lightScheme.toColorScheme());

  /// The dark themes of the app.
  static ThemeData get dark =>
      _buildTheme(AppColors.darkScheme.toColorScheme());

  /// The high contrast light themes of the app.
  static ThemeData get lightHighContrast =>
      _buildTheme(AppColors.lightHighContrastScheme.toColorScheme());

  /// The high contrast dark themes of the app.
  static ThemeData get darkHighContrast =>
      _buildTheme(AppColors.darkHighContrastScheme.toColorScheme());

  /// Builds a themes based on the given color scheme.
  ///
  /// It uses the existing text themes and widget themes, and applies the given
  /// color scheme to them.
  static ThemeData _buildTheme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,

        //TextTheme
        textTheme: AppFonts.textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),

        //Colors
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,

        //Widget themes
        inputDecorationTheme: AppWidgetThemes.inputDecoration(
          colorScheme,
          AppFonts.textTheme,
        ),
        dropdownMenuTheme: AppWidgetThemes.dropdownMenu(
          colorScheme,
          AppFonts.textTheme,
        ),
        elevatedButtonTheme: AppWidgetThemes.elevatedButton(
          colorScheme,
          AppFonts.textTheme,
        ),
        outlinedButtonTheme: AppWidgetThemes.outlinedButton(
          colorScheme,
          AppFonts.textTheme,
        ),
        textButtonTheme: AppWidgetThemes.textButton(
          colorScheme,
          AppFonts.textTheme,
        ),
        appBarTheme: AppWidgetThemes.appBar(colorScheme, AppFonts.textTheme),
        iconButtonTheme: AppWidgetThemes.iconButton(colorScheme),
        switchTheme: AppWidgetThemes.switchThemeData(colorScheme),
        sliderTheme: AppWidgetThemes.sliderThemeData(colorScheme),
        chipTheme:
            AppWidgetThemes.chipThemeData(colorScheme, AppFonts.textTheme),
      );
}
