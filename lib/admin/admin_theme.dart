import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Colours used only by the admin portal.
class AdminColors {
  static const sidebar = Color(0xFF0A291D); // BiteBox deep forest green
  static const sidebarHover = Color(0xFF123D2C);
  static const primary = AppTheme.brandGreen;
  static const primaryDark = AppTheme.brandGreenDark;
  static const accent = Color(0xFFD97706); // BiteBox amber
  static const background = Color(0xFFF3F6F4);
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const text = Color(0xFF1E293B);
  static const muted = Color(0xFF64748B);
  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const success = Color(0xFF059669);
}

ThemeData buildAdminTheme() {
  final base = AppTheme.buildTheme(AppThemePreset.greenYellow);
  final outline = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AdminColors.border),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AdminColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AdminColors.primary,
      secondary: AdminColors.accent,
      surface: AdminColors.surface,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      fillColor: const Color(0xFFF8FAFC),
      border: outline,
      enabledBorder: outline,
      focusedBorder: outline.copyWith(
        borderSide: const BorderSide(color: AdminColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminColors.text,
        side: const BorderSide(color: AdminColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AdminColors.text,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
