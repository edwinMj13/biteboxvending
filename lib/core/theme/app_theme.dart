import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemePreset { greenYellow, yellowGreen }

final themePresetProvider = StateProvider<AppThemePreset>(
  (ref) => AppThemePreset.greenYellow,
);

class AppTheme {
  // Preset Core Colors
  static const Color brandGreen = Color(0xFF10B981);
  static const Color brandGreenDark = Color(0xFF047857);

  static const Color brandYellow = Color(0xFFFFD369);
  static const Color brandYellowDark = Color(0xFFD97706);

  static const Color primaryTeal = brandGreen;
  static const Color accentYellow = brandYellow;

  // Custom non-charcoal light themes
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E293B); // Slate-colored text
  static const Color darkText = Color(0xFFF8FAFC);

  // Dynamic getters based on current build context
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color primaryDark(BuildContext context) {
    final isGreen = Theme.of(context).colorScheme.primary == brandGreen;
    return isGreen ? brandGreenDark : brandYellowDark;
  }

  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  // Dynamic dark theme colors (Sidebar, Footer, Hero banners) to replace charcoal
  static Color darkColor(BuildContext context) {
    final isGreenBg = Theme.of(context).scaffoldBackgroundColor == const Color(0xFFD3EFE3);
    return isGreenBg
        ? const Color(0xFF0A291D)
        : const Color(0xFF2C220E); // Deep Forest Green vs Deep Golden Brown
  }

  static Color greyColor(BuildContext context) {
    final isGreenBg = Theme.of(context).scaffoldBackgroundColor == const Color(0xFFD3EFE3);
    return isGreenBg
        ? const Color(0xFF1E4839)
        : const Color(0xFF4C3E1B); // Slate-Green vs Slate-Golden
  }

  static ThemeData buildTheme(AppThemePreset preset) {
    final primaryColor = preset == AppThemePreset.greenYellow
        ? const Color(0xFFD97706) // Rich yellow/amber highlight
        : const Color(0xFF10B981); // Brand green highlight
    final secondaryColor = preset == AppThemePreset.greenYellow
        ? const Color(0xFF10B981) // Brand green shades
        : const Color(0xFFD97706); // Rich yellow/amber shades
    final scaffoldBgColor = preset == AppThemePreset.greenYellow
        ? const Color(0xFFD3EFE3) // Noticeable light green background
        : const Color(0xFFFFF0C5) // Noticeable light yellow background
          ;
    final surfaceColor = preset == AppThemePreset.greenYellow
        ? const Color(0xFFEBF7F2) // Light mint green surface for cards
        : const Color(0xFFFFFBF0); // Light cream yellow surface for cards

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBgColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: lightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightText),
        titleTextStyle: const TextStyle(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryColor.withOpacity(0.12),
            width: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: lightText,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
      ),
    );
  }

  // Global stunning decorations matching primary and secondary colors
  static BoxDecoration bannerDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primary(context),
          primaryDark(context),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static BoxDecoration sectionDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primary(context).withOpacity(0.06),
          secondary(context).withOpacity(0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: primary(context).withOpacity(0.12),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: primary(context).withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration accentCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: secondary(context).withOpacity(0.35),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: primary(context).withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
