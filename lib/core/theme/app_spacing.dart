import 'package:flutter/material.dart';

/// 8px Spacing System and Radii Tokens
class AppSpacing {
  static const double s2  = 2.0;
  static const double s4  = 4.0;
  static const double s6  = 6.0;
  static const double s8  = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // Page level
  static const double pagePadding = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;
}

/// Standardized Corner Radii
class AppRadius {
  static const double xs  = 4.0;
  static const double sm  = 8.0;   // Small elements, tags
  static const double md  = 12.0;  // Buttons, text fields
  static const double lg  = 16.0;  // Cards, tiles
  static const double xl  = 20.0;  // Modals, large cards
  static const double xxl = 24.0;  // Bottom sheets top radius
  static const double full = 999.0;// Pills & round avatars

  static final BorderRadius smBorderRadius  = BorderRadius.circular(sm);
  static final BorderRadius mdBorderRadius  = BorderRadius.circular(md);
  static final BorderRadius lgBorderRadius  = BorderRadius.circular(lg);
  static final BorderRadius xlBorderRadius  = BorderRadius.circular(xl);
  static const BorderRadius sheetBorderRadius = BorderRadius.vertical(top: Radius.circular(xxl));
}

/// Standardized Subtle Shadows & Depth
class AppShadows {
  // Default Card: 0 2px 8px rgba(16, 24, 40, 0.05)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Elevated Card / Dropdown: 0 4px 16px rgba(16, 24, 40, 0.08)
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.08),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Modal / Bottom Sheet: 0 12px 32px rgba(16, 24, 40, 0.12)
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.12),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  // Dark Mode subtle shadow
  static const List<BoxShadow> darkCard = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.25),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
