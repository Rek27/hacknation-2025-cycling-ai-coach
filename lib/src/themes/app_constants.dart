/// Provides predefined constants for border radius values.
///
/// Each constant represents a specific border radius value that can be used
/// throughout the application for consistency.
///
/// The constants are:
/// - `xxs`: Used only to avoid a rectangle border.
/// - `xs`: For the smaller containers.
/// - `s`: For buttons and small input fields.
/// - `m`: For modal dialogues and cards.
/// - `l`: For larger elements or to create a more pronounced rounded effect.
/// - `xl`: For elements that require a circular or highly rounded shape.
class Radiuses {
  /// For the most subtle curvature, to avoid a rectangle border.
  static const double xxs = 2;

  /// For the smaller containers.
  static const double xs = 5;

  /// For buttons and small input fields.
  static const double s = 10;

  /// For modal dialogues and cards.
  static const double m = 20;

  /// For larger elements or to create a more pronounced rounded effect.
  static const double l = 30;

  /// For elements that require a circular or highly rounded shape.
  static const double xl = 60;
}

/// `Spacings` is a class that provides predefined constants for spacing values.
///
/// - `xxs`: Between closely grouped elements.
/// - `xs`: Between text elements.
/// - `s`: Between form elements.
/// - `m`: Between sections of a page.
/// - `l`: Between distinct groups of elements.
/// - `xl`: Between distinct sections of a layout.
/// - `xxl`: Between major layout blocks.
class Spacings {
  /// Extra extra small spacing, typically used between closely grouped elements.
  static const double xxs = 2;

  /// Extra small spacing, suitable for spacing between text elements.
  static const double xs = 4;

  /// Small spacing, ideal for spacing between form elements.
  static const double s = 8;

  /// Medium spacing, used between sections of a page.
  static const double m = 12;

  /// Large spacing, applied between distinct groups of elements.
  static const double l = 16;

  /// Extra large spacing, used between distinct sections of a layout.
  static const double xl = 32;

  /// Extra extra large spacing, ideal for spacing between major layout blocks.
  static const double xxl = 64;
}

/// `IconSizes` is a class that provides predefined constants for icon sizes.
///
/// - `xs`: For very small icons, such as in compact toolbars or list items.
/// - `s`: For small icons, such as in standard toolbars or buttons.
/// - `m`: For medium icons, such as in dialog titles or larger buttons.
/// - `l`: For large icons, such as in onboarding screens or empty states.
/// - `xl`: For very large icons, such as in splash screens or large empty states.
/// - `xxl`: For extra large icons, such as in full-screen illustrations.
class IconSizes {
  /// Extra small size for icons, used for very small UI elements such as compact toolbars or list items.
  static const double xs = 16;

  /// Small size for icons, suitable for standard toolbars or buttons.
  static const double s = 24;

  /// Medium size for icons, ideal for dialog titles or larger buttons.
  static const double m = 32;

  /// Large size for icons, used in onboarding screens or empty states.
  static const double l = 48;

  /// Extra large size for icons, perfect for splash screens or large empty states.
  static const double xl = 64;

  /// Extra extra large size for icons, good for screen illustrations.
  static const double xxl = 96;

  /// Extra extra extra large size for icons, typically used in full-screen illustrations.
  static const double xxxl = 128;
}

/// `Elevations` is a class that provides predefined constants for elevation values.
///
/// - `xxs`: For very subtle elevation for inactive or subtle UI elements.
/// - `xs`: For slightly more noticeable depth.
/// - `s`: For common slightly elevated UI components like list items.
/// - `m`: For medium elevation for cards or small dialog boxes.
/// - `l`: For larger elevation for modal elements or important cards.
/// - `xl`: For more pronounced elevation for important interactive elements.
/// - `xxl`: For highest typical elevation, used for critical components like
/// floating action buttons.
class Elevations {
  /// No elevation, used for flat UI elements.
  static const double none = 0;

  /// Very subtle elevation for inactive or subtle UI elements.
  static const double xxs = 1;

  /// Slightly more noticeable, for slight depth.
  static const double xs = 2;

  /// Common for slightly elevated UI components like list items.
  static const double s = 4;

  /// Medium elevation for cards or small dialog boxes.
  static const double m = 6;

  /// Larger elevation for modal elements or important cards.
  static const double l = 8;

  /// More pronounced for important interactive elements.
  static const double xl = 12;

  /// Highest typical elevation, used for critical components like floating action buttons.
  static const double xxl = 16;
}

/// `borderWidth` is a class that provides predefined constants for border width
/// values.
class BorderWidth {
  /// Used as the default border stroke.
  static const double m = 1.5;
  static const double l = 2;
}
