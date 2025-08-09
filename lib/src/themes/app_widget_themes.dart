import 'package:flutter/material.dart';
import 'package:hackathon/src/themes/app_constants.dart';

/// Provides predefined themes for various widgets in the application.
class AppWidgetThemes {
  /// Creates and returns the theme for text fields.
  ///
  /// The borders are slightly rounded, and it is not filled. The color of the
  /// border is dark by default, but changes to the primary color when focused
  /// and to grey when disabled. The hint text is grey.
  static InputDecorationTheme inputDecoration(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacings.s),
      filled: false,
      iconColor: colorScheme.outline,
      prefixIconColor: colorScheme.outline,
      suffixIconColor: colorScheme.outline,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: BorderWidth.m,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: BorderWidth.l,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
        borderSide: BorderSide(
          color: colorScheme.onSurface,
          width: BorderWidth.m,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: BorderWidth.m,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
        borderSide: BorderSide(color: colorScheme.error, width: BorderWidth.m),
      ),
      hintStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.error)) {
          return textTheme.bodyMedium!.copyWith(color: colorScheme.error);
        }
        return textTheme.bodyMedium!.copyWith(color: colorScheme.outline);
      }),
      labelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return textTheme.bodyMedium!.copyWith(color: colorScheme.primary);
        }
        if (states.contains(WidgetState.error)) {
          return textTheme.bodyMedium!.copyWith(color: colorScheme.error);
        }
        if (states.contains(WidgetState.disabled)) {
          return textTheme.bodyMedium!.copyWith(
            color: colorScheme.outlineVariant,
          );
        }
        return textTheme.bodyMedium!.copyWith(color: colorScheme.outline);
      }),
    );
  }

  /// Creates and returns a [DropdownMenuThemeData].
  ///
  /// The [ColorScheme] parameter is used to customize the color scheme of the
  /// dropdown menu.
  static DropdownMenuThemeData dropdownMenu(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacings.s),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radiuses.s),
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(colorScheme.surface),
        elevation: WidgetStateProperty.all(Elevations.s),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radiuses.s),
          ),
        ),
      ),
      textStyle: textTheme.bodyMedium,
    );
  }

  /// Creates and returns a theme for elevated buttons, which is equivalent to
  /// a primary button.
  ///
  /// The button has the primary color as its background color. When disabled,
  /// the button is greyed out.
  static ElevatedButtonThemeData elevatedButton(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        alignment: Alignment.center,
        elevation: WidgetStateProperty.all(Elevations.none),
        minimumSize: WidgetStateProperty.all(Size(0, 40)),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: Spacings.m),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radiuses.s),
          ),
        ),
        textStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return textTheme.titleSmall!.copyWith(color: colorScheme.outline);
          }
          return textTheme.titleSmall!.copyWith(color: colorScheme.onPrimary);
        }),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primaryContainer;
          }
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outlineVariant;
          }
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outline;
          }
          return colorScheme.onPrimary;
        }),
        iconColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outline;
          }
          return colorScheme.onPrimary;
        }),
        shadowColor: WidgetStateProperty.all(colorScheme.primaryContainer),
      ),
    );
  }

  /// Creates and returns a theme for outlined buttons, which is equivalent to
  /// a secondary button.
  ///
  /// The button has the primary color as its border color. When disabled, the
  /// button is greyed out.
  static OutlinedButtonThemeData outlinedButton(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        alignment: Alignment.center,
        elevation: WidgetStateProperty.all(Elevations.none),
        minimumSize: WidgetStateProperty.all(Size(0, 40)),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: Spacings.m),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radiuses.s),
          ),
        ),
        textStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return textTheme.titleSmall!.copyWith(color: colorScheme.outline);
          }
          return textTheme.titleSmall!.copyWith(color: colorScheme.primary);
        }),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outline;
          }
          return colorScheme.primary;
        }),
        iconColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outline;
          }
          return colorScheme.primary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: colorScheme.outline, width: BorderWidth.m);
          }
          return BorderSide(color: colorScheme.primary, width: BorderWidth.m);
        }),
        shadowColor: WidgetStateProperty.all(colorScheme.primaryContainer),
      ),
    );
  }

  /// Creates and returns a theme for text buttons, which is equivalent to a
  /// tertiary button.
  ///
  /// The button has the primary color as its text color. When disabled, the
  /// button is greyed out.
  static TextButtonThemeData textButton(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TextButtonThemeData(
      style: ButtonStyle(
        alignment: Alignment.center,
        elevation: WidgetStateProperty.all(Elevations.none),
        minimumSize: WidgetStateProperty.all(Size(0, 40)),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radiuses.s),
          ),
        ),
        textStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return textTheme.titleSmall!.copyWith(color: colorScheme.outline);
          }
          return textTheme.titleSmall!.copyWith(color: colorScheme.primary);
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outline;
          }
          return colorScheme.primary;
        }),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        iconColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outline;
          }
          return colorScheme.primary;
        }),
        shadowColor: WidgetStateProperty.all(colorScheme.primaryContainer),
      ),
    );
  }

  /// Creates and returns a theme for app bars.
  ///
  /// The app bar has no elevation, a background color that matches the
  /// background color of the color scheme, and a title text style that matches
  /// the headline medium text style of the text theme. The title is centered,
  /// and the icon color is the on background color of the color scheme.
  static AppBarTheme appBar(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      centerTitle: true,
      elevation: Elevations.none,
      iconTheme: IconThemeData(color: colorScheme.primary),
    );
  }

  /// Creates and returns a theme for icon buttons.
  ///
  /// The icon button has no padding.
  static IconButtonThemeData iconButton(ColorScheme colorScheme) {
    return IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
    );
  }

  /// Creates and returns a theme for switch widgets.
  ///
  /// The colors change based on the state of the switch.
  static SwitchThemeData switchThemeData(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.surface;
        }
        return colorScheme.surface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.outlineVariant;
        } else if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outlineVariant;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      }),
      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return Icon(Icons.circle, size: 20.0, color: colorScheme.surface);
        }
        return Icon(Icons.circle, size: 20.0, color: colorScheme.surface);
      }),
    );
  }

  /// Creates and returns a theme for slider widgets.
  ///
  /// It uses mainly the primary color of the color scheme.
  static SliderThemeData sliderThemeData(ColorScheme colorScheme) {
    return SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.4),
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withValues(alpha: 0.2),
      valueIndicatorColor: colorScheme.outlineVariant,
      valueIndicatorTextStyle: TextStyle(color: colorScheme.onSurface),
    );
  }

  /// Creates and returns a theme for chip widgets.
  static ChipThemeData chipThemeData(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ChipThemeData(
      backgroundColor: colorScheme.outlineVariant,
      padding: const EdgeInsets.all(Spacings.xs),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(Radiuses.xs),
      ),
      labelStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
      brightness: colorScheme.brightness,
    );
  }

  static CardTheme cardTheme(ColorScheme colorScheme) {
    return CardTheme(
      color: colorScheme.surface,
      elevation: Elevations.s,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radiuses.s),
      ),
    );
  }
}
