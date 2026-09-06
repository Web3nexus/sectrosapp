import 'package:flutter/material.dart';

/// Modern Hospitality SaaS Design System Colors
class AppColors {
  // ── Primary Brand: Vibrant Emerald / Hospitality Green ───────────────────
  static const primary          = Color(0xFF11C685); // Main primary brand (new logo)
  static const primaryDark      = Color(0xFF0EA870); // Pressed / hover
  static const primaryLight     = Color(0xFFD1FAE5); // Soft tint / active container
  static const primaryBlue      = Color(0xFF0071E3); // Alternate classic blue brand

  // ── Dark Navy: Contextual Headers & High Priority ─────────────────────────
  static const darkNavy         = Color(0xFF172A3A); // Property headers, dark cards
  static const navyLight        = Color(0xFF243B4D); // Elevated navy surface
  static const navyCardTextMuted = Color(0xFF8FA2B4); // Light slate for navy card secondary text

  // ── Neutral Surfaces & Backgrounds ────────────────────────────────────────
  static const surface          = Color(0xFFFFFFFF); // Card & modal surface
  static const background       = Color(0xFFF7F8FA); // Main scaffold background
  static const secondaryBackground = Color(0xFFF1F4F6); // Grouped / secondary bg
  static const white            = Color(0xFFFFFFFF);

  // ── Typography ────────────────────────────────────────────────────────────
  static const textPrimary      = Color(0xFF17212B); // High contrast body & titles
  static const textSecondary    = Color(0xFF667085); // Secondary info & sublabels
  static const textMuted        = Color(0xFF98A2B3); // Captions, placeholders, disabled

  // Aliases for compatibility
  static const foreground       = textPrimary;
  static const mutedForeground  = textSecondary;

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const border           = Color(0xFFE4E7EC); // Card & input borders
  static const divider          = Color(0xFFEEF0F2); // Subtle row dividers
  static const card             = Color(0xFFFFFFFF);
  static const muted            = Color(0xFFF1F4F6);

  // ── Semantic Status Colors ────────────────────────────────────────────────
  // Success / Confirmed / Available
  static const success          = Color(0xFF12B886);
  static const successLight     = Color(0xFFDDF7EF);

  // Warning / Pending / Attention
  static const warning          = Color(0xFFF59E0B);
  static const warningLight     = Color(0xFFFFF4D6);
  static const accent           = warning;

  // Error / Cancelled / Critical
  static const error            = Color(0xFFE5484D);
  static const errorLight       = Color(0xFFFDE8E8);
  static const destructive      = error;

  // Info / System
  static const info             = Color(0xFF3B82F6);
  static const infoLight        = Color(0xFFE8F1FF);
  static const secondary        = info;

  // Neutral / Completed
  static const neutral          = Color(0xFF667085);
  static const neutralLight      = Color(0xFFF2F4F7);
  static const blocked          = Color(0xFF344054);

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const darkBackground   = Color(0xFF0F1720); // Scaffold background
  static const darkSurface      = Color(0xFF17212B); // Cards & bottom sheets
  static const darkCard         = Color(0xFF17212B);
  static const darkElevated     = Color(0xFF1E2D3A); // Modals & elevated cards
  static const darkTextPrimary  = Color(0xFFF8FAFC); // Primary text
  static const darkTextSecondary= Color(0xFFA7B0BA); // Secondary text
  static const darkBorder       = Color(0xFF2A3947); // Dark separators & borders
  static const darkPrimaryTeal  = Color(0xFF19C99A); // High visibility teal
  static const darkForeground   = darkTextPrimary;
  static const darkMuted        = Color(0xFF1E2D3A);

  // ── Gray Scale ────────────────────────────────────────────────────────────
  static const gray50  = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF2F4F7);
  static const gray200 = Color(0xFFE4E7EC);
  static const gray300 = Color(0xFFD0D5DD);
  static const gray400 = Color(0xFF98A2B3);
  static const gray500 = Color(0xFF667085);
  static const gray600 = Color(0xFF475467);
  static const gray700 = Color(0xFF344054);
  static const gray800 = Color(0xFF1D2939);
  static const gray900 = Color(0xFF101828);
}
