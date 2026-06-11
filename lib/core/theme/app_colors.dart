import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Primary ─────────────────────────────────────────────────────────
  // A calm, confident blue – closer to Apple/iOS blue than the previous
  // electric Tailwind blue.
  static const primary        = Color(0xFF0071E3); // Apple-style blue
  static const primaryLight   = Color(0xFF409CFF); // lighter variant
  static const primaryDark    = Color(0xFF0052A3); // pressed/dark variant

  // ── Accent / Secondary ────────────────────────────────────────────────────
  static const secondary      = Color(0xFF5856D6); // iOS purple
  static const accent         = Color(0xFFFF9500); // iOS amber / warm orange
  static const success        = Color(0xFF34C759); // iOS green
  static const destructive    = Color(0xFFFF3B30); // iOS red

  // ── Light Mode Neutrals ───────────────────────────────────────────────────
  static const white          = Color(0xFFFFFFFF);
  static const background     = Color(0xFFF5F5F7); // Apple off-white
  static const foreground     = Color(0xFF1D1D1F); // Apple near-black
  static const muted          = Color(0xFFF2F2F7); // iOS system gray 6
  static const mutedForeground= Color(0xFF8E8E93); // iOS secondary text
  static const border         = Color(0xFFE5E5EA); // iOS separator
  static const card           = Color(0xFFFFFFFF); // pure white card

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF000000); // true black (OLED)
  static const darkForeground = Color(0xFFF5F5F7); // off-white text
  static const darkCard       = Color(0xFF1C1C1E); // iOS dark surface
  static const darkMuted      = Color(0xFF2C2C2E); // iOS dark gray 5
  static const darkBorder     = Color(0xFF38383A); // iOS dark separator

  // ── Convenience Grays (replaces old slate scale) ──────────────────────────
  static const gray50  = Color(0xFFF5F5F7);
  static const gray100 = Color(0xFFE5E5EA);
  static const gray200 = Color(0xFFD1D1D6);
  static const gray300 = Color(0xFFC7C7CC);
  static const gray400 = Color(0xFFAEAEB2);
  static const gray500 = Color(0xFF8E8E93);
  static const gray600 = Color(0xFF636366);
  static const gray700 = Color(0xFF48484A);
  static const gray800 = Color(0xFF3A3A3C);
  static const gray900 = Color(0xFF2C2C2E);
  static const gray950 = Color(0xFF1C1C1E);
}
