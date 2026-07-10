import 'package:couples_space/features/profile/data/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFFFBF3EC);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFFEF9270);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primarySoft = Color(0xFFFBE0D3);
  static const text = Color(0xFF4B3A33);
  static const muted = Color(0xFFA99184);
  static const chipBg = Color(0xFFF6E7DC);
  static const chipText = Color(0xFF9A6B4E);
  static const border = Color(0xFFF0E4DA);
  static const failText = Color(0xFFC25B3A);
  static const failBg = Color(0xFFFBE0D3);

  /// Five pastel tile colors cycled by list index: `tilePalette[i % 5]`.
  static const List<({Color background, Color iconColor})> tilePalette = [
    (background: Color(0xFFFBE0D3), iconColor: Color(0xFFE07A54)), // peach
    (background: Color(0xFFE7EEDD), iconColor: Color(0xFF7FA05B)), // sage
    (background: Color(0xFFFCE7C8), iconColor: Color(0xFFD69A3E)), // butter
    (background: Color(0xFFF6DDE0), iconColor: Color(0xFFD06A82)), // rose
    (background: Color(0xFFDDEAEA), iconColor: Color(0xFF5E9A9A)), // teal
  ];
}

class AppTheme {
  AppTheme._();

  /// Soft warm shadow for cards and list items.
  static const cardShadow = BoxShadow(
    color: Color(0x21B4785A), // rgba(180,120,90,0.13)
    blurRadius: 22,
    offset: Offset(0, 8),
  );

  /// Coral glow shadow for primary buttons and FAB.
  static const buttonShadow = BoxShadow(
    color: Color(0x52E07A54), // rgba(224,122,84,0.32)
    blurRadius: 22,
    offset: Offset(0, 10),
  );

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.text,
      secondary: AppColors.chipText,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.chipBg,
      onSecondaryContainer: AppColors.chipText,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.failText,
      onError: AppColors.onPrimary,
      errorContainer: AppColors.failBg,
      onErrorContainer: AppColors.failText,
    ),
    textTheme: _textTheme(),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.chipBg,
      labelStyle: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.chipText,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.muted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
  );

  static ThemeMode toThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static TextTheme _textTheme() => TextTheme(
    displayLarge: GoogleFonts.baloo2(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.text),
    displayMedium: GoogleFonts.baloo2(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.text),
    displaySmall: GoogleFonts.baloo2(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.text),
    headlineLarge: GoogleFonts.baloo2(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.text),
    headlineMedium: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.text),
    headlineSmall: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text),
    titleLarge: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.text),
    titleMedium: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
    titleSmall: GoogleFonts.baloo2(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
    bodyLarge: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.text),
    bodyMedium: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text),
    bodySmall: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted),
    labelLarge: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
    labelMedium: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted),
    labelSmall: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted),
  );
}
