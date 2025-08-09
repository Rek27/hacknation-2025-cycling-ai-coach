import 'package:flutter/material.dart';

/// Contains all the colors schemes of the app.
///
/// The main colors are:
/// - Primary color: Deep Teal, #004346
/// - Secondary color: Emerald Green, #08AF80
/// - Tertiary color: Muted Blue-Green, #508991
/// - Surface: Light Blue-Gray, #E3EEF2
/// - On Surface: Dark Blue-Gray, #172A3A
/// - Outline: Light Blue, #A4CEDF
/// - Additional: Medium Blue-Gray, #629EB0
class AppColors {
  /// The light color scheme of the app.
  static MaterialScheme get lightScheme => const MaterialScheme(
        brightness: Brightness.light,

        // Primary
        primary: Color(0xFF004346),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF002E31),
        onPrimaryContainer: Color(0xFFFFFFFF),
        inversePrimary: Color(0xFF629EB0),
        primaryFixed: Color(0xFF629EB0),
        primaryFixedDim: Color(0xFF508991),
        onPrimaryFixed: Color(0xFFFFFFFF),
        onPrimaryFixedVariant: Color(0xFF002E31),

        // Secondary
        secondary: Color(0xFF08AF80),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFF006B4F),
        onSecondaryContainer: Color(0xFFFFFFFF),
        secondaryFixed: Color(0xFF629EB0),
        secondaryFixedDim: Color(0xFF508991),
        onSecondaryFixed: Color(0xFFFFFFFF),
        onSecondaryFixedVariant: Color(0xFF006B4F),

        // Tertiary
        tertiary: Color(0xFF508991),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF2D5A61),
        onTertiaryContainer: Color(0xFFFFFFFF),
        tertiaryFixed: Color(0xFF629EB0),
        onTertiaryFixed: Color(0xFFFFFFFF),
        tertiaryFixedDim: Color(0xFF508991),
        onTertiaryFixedVariant: Color(0xFF2D5A61),

        // Outline
        outline: Color(0xFFA4CEDF),
        outlineVariant: Color(0xFFB8D8E6),

        // Background
        background: Color(0xFFE3EEF2),
        onBackground: Color(0xFF172A3A),

        // Surface
        surface: Color(0xFFE3EEF2),
        onSurface: Color(0xFF172A3A),
        inverseSurface: Color(0xFF172A3A),
        inverseOnSurface: Color(0xFFE3EEF2),
        surfaceVariant: Color(0xFFD1E5EB),
        onSurfaceVariant: Color(0xFF2A3F4F),
        surfaceTint: Color(0xFF004346),
        surfaceDim: Color(0xFFC3D5DB),
        surfaceBright: Color(0xFFE3EEF2),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF0F6F9),
        surfaceContainer: Color(0xFFEAF2F6),
        surfaceContainerHigh: Color(0xFFE4EDF1),
        surfaceContainerHighest: Color(0xFFDEE8EC),

        // Error
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),

        // Others
        shadow: Color(0xFF004346),
        scrim: Color(0xFF000000),
      );

  /// The dark color scheme of the app.
  static MaterialScheme get darkScheme => const MaterialScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF629EB0),
        surfaceTint: Color(0xFF629EB0),
        onPrimary: Color(0xFF001F22),
        primaryContainer: Color(0xFF004346),
        onPrimaryContainer: Color(0xFFA4CEDF),
        secondary: Color(0xFF508991),
        onSecondary: Color(0xFF001F22),
        secondaryContainer: Color(0xFF006B4F),
        onSecondaryContainer: Color(0xFF629EB0),
        tertiary: Color(0xFF629EB0),
        onTertiary: Color(0xFF001F22),
        tertiaryContainer: Color(0xFF2D5A61),
        onTertiaryContainer: Color(0xFFA4CEDF),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        background: Color(0xFF0F1A23),
        onBackground: Color(0xFFDEE8EC),
        surface: Color(0xFF0F1A23),
        onSurface: Color(0xFFDEE8EC),
        surfaceVariant: Color(0xFF2A3F4F),
        onSurfaceVariant: Color(0xFFB8D8E6),
        outline: Color(0xFF629EB0),
        outlineVariant: Color(0xFF2A3F4F),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFDEE8EC),
        inverseOnSurface: Color(0xFF0F1A23),
        inversePrimary: Color(0xFF004346),
        primaryFixed: Color(0xFFA4CEDF),
        onPrimaryFixed: Color(0xFF001F22),
        primaryFixedDim: Color(0xFF629EB0),
        onPrimaryFixedVariant: Color(0xFF004346),
        secondaryFixed: Color(0xFFA4CEDF),
        onSecondaryFixed: Color(0xFF001F22),
        secondaryFixedDim: Color(0xFF508991),
        onSecondaryFixedVariant: Color(0xFF006B4F),
        tertiaryFixed: Color(0xFFA4CEDF),
        onTertiaryFixed: Color(0xFF001F22),
        tertiaryFixedDim: Color(0xFF629EB0),
        onTertiaryFixedVariant: Color(0xFF2D5A61),
        surfaceDim: Color(0xFF0F1A23),
        surfaceBright: Color(0xFF1F2A33),
        surfaceContainerLowest: Color(0xFF0A151E),
        surfaceContainerLow: Color(0xFF0F1A23),
        surfaceContainer: Color(0xFF131E27),
        surfaceContainerHigh: Color(0xFF1D2831),
        surfaceContainerHighest: Color(0xFF27323B),
      );

  /// The light high contrast color scheme of the app.
  static MaterialScheme get lightHighContrastScheme => const MaterialScheme(
        brightness: Brightness.light,
        primary: Color(0xFF001F22),
        surfaceTint: Color(0xFF004346),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF004346),
        onPrimaryContainer: Color(0xFFFFFFFF),
        secondary: Color(0xFF004D3A),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFF006B4F),
        onSecondaryContainer: Color(0xFFFFFFFF),
        tertiary: Color(0xFF1A3A40),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF2D5A61),
        onTertiaryContainer: Color(0xFFFFFFFF),
        error: Color(0xFF4E0002),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFF8E0004),
        onErrorContainer: Color(0xFFFFFFFF),
        background: Color(0xFFE3EEF2),
        onBackground: Color(0xFF000000),
        surface: Color(0xFFE3EEF2),
        onSurface: Color(0xFF000000),
        surfaceVariant: Color(0xFFD1E5EB),
        onSurfaceVariant: Color(0xFF000000),
        outline: Color(0xFF004346),
        outlineVariant: Color(0xFF004346),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF172A3A),
        inverseOnSurface: Color(0xFFFFFFFF),
        inversePrimary: Color(0xFFA4CEDF),
        primaryFixed: Color(0xFF004346),
        onPrimaryFixed: Color(0xFFFFFFFF),
        primaryFixedDim: Color(0xFF002E31),
        onPrimaryFixedVariant: Color(0xFFFFFFFF),
        secondaryFixed: Color(0xFF006B4F),
        onSecondaryFixed: Color(0xFFFFFFFF),
        secondaryFixedDim: Color(0xFF004D3A),
        onSecondaryFixedVariant: Color(0xFFFFFFFF),
        tertiaryFixed: Color(0xFF2D5A61),
        onTertiaryFixed: Color(0xFFFFFFFF),
        tertiaryFixedDim: Color(0xFF1A3A40),
        onTertiaryFixedVariant: Color(0xFFFFFFFF),
        surfaceDim: Color(0xFFC3D5DB),
        surfaceBright: Color(0xFFE3EEF2),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF0F6F9),
        surfaceContainer: Color(0xFFEAF2F6),
        surfaceContainerHigh: Color(0xFFE4EDF1),
        surfaceContainerHighest: Color(0xFFDEE8EC),
      );

  /// The dark high contrast color scheme of the app.
  static MaterialScheme get darkHighContrastScheme => const MaterialScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFA4CEDF),
        surfaceTint: Color(0xFF629EB0),
        onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFF629EB0),
        onPrimaryContainer: Color(0xFF000000),
        secondary: Color(0xFFA4CEDF),
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF508991),
        onSecondaryContainer: Color(0xFF000000),
        tertiary: Color(0xFFA4CEDF),
        onTertiary: Color(0xFF000000),
        tertiaryContainer: Color(0xFF629EB0),
        onTertiaryContainer: Color(0xFF000000),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF000000),
        errorContainer: Color(0xFFFFB4AB),
        onErrorContainer: Color(0xFF000000),
        background: Color(0xFF0F1A23),
        onBackground: Color(0xFFFFFFFF),
        surface: Color(0xFF0F1A23),
        onSurface: Color(0xFFFFFFFF),
        surfaceVariant: Color(0xFF2A3F4F),
        onSurfaceVariant: Color(0xFFFFFFFF),
        outline: Color(0xFFA4CEDF),
        outlineVariant: Color(0xFFA4CEDF),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFDEE8EC),
        inverseOnSurface: Color(0xFF000000),
        inversePrimary: Color(0xFF001F22),
        primaryFixed: Color(0xFFA4CEDF),
        onPrimaryFixed: Color(0xFF000000),
        primaryFixedDim: Color(0xFF629EB0),
        onPrimaryFixedVariant: Color(0xFF000000),
        secondaryFixed: Color(0xFFA4CEDF),
        onSecondaryFixed: Color(0xFF000000),
        secondaryFixedDim: Color(0xFF508991),
        onSecondaryFixedVariant: Color(0xFF000000),
        tertiaryFixed: Color(0xFFA4CEDF),
        onTertiaryFixed: Color(0xFF000000),
        tertiaryFixedDim: Color(0xFF629EB0),
        onTertiaryFixedVariant: Color(0xFF000000),
        surfaceDim: Color(0xFF0F1A23),
        surfaceBright: Color(0xFF1F2A33),
        surfaceContainerLowest: Color(0xFF0A151E),
        surfaceContainerLow: Color(0xFF0F1A23),
        surfaceContainer: Color(0xFF131E27),
        surfaceContainerHigh: Color(0xFF1D2831),
        surfaceContainerHighest: Color(0xFF27323B),
      );
}

/// Contains all the colors of the app.
class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  /// Converts the MaterialScheme to a ColorScheme.
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}
