import 'package:flutter/material.dart';

/// 바다/조개 브랜드를 유지하되 토론 도구답게 차분한 제품 톤을 제공한다.
class AppTheme {
  const AppTheme._();

  static const primaryTeal = Color(0xFF22B8B7);
  static const primaryLight = Color(0xFF96E5DE);
  static const primaryDark = Color(0xFF167A83);
  static const primaryBg = Color(0xFFF9FDF8);
  static const accentGold = Color(0xFFFFDC5B);
  static const accentLight = Color(0xFFFFEE9D);
  static const accentDark = Color(0xFFE1AD19);
  static const coral = Color(0xFFFF8194);
  static const coralLight = Color(0xFFFFAEC0);
  static const coralDark = Color(0xFFE75E7A);
  static const shellPink = Color(0xFFFF8FCC);
  static const shellPurple = Color(0xFFC0A0FF);
  static const cream = Color(0xFFFFFAE8);
  static const skyBlue = Color(0xFF6BD1F0);
  static const surfaceBase = Color(0xFFF1FAF5);
  static const surfaceCard = Color(0xFFFFFEF8);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEAF8F4);
  static const success = Color(0xFF28A76E);
  static const error = Color(0xFFE55A50);
  static const textPrimary = Color(0xFF174B4D);
  static const textSecondary = Color(0xFF5F7774);
  static const textTertiary = Color(0xFF8CA39F);
  static const border = Color(0xFFDCEBE5);
  static const borderStrong = Color(0xFFBEE2DB);
  static const glassBorder = Color(0xFFD9ECE7);
  static const shadowTint = Color(0xFF1FA6A5);

  static const panelRadius = 26.0;
  static const controlRadius = 22.0;
  static const softControlRadius = 28.0;
  static const pillRadius = 999.0;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      primary: primaryTeal,
      onPrimary: Colors.white,
      primaryContainer: primaryLight,
      secondary: shellPink,
      onSecondary: Colors.white,
      secondaryContainer: accentLight,
      surface: surfaceRaised,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceMuted,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: primaryBg,
      canvasColor: primaryBg,
      fontFamilyFallback: const [
        'Apple SD Gothic Neo',
        'Noto Sans KR',
        'Roboto',
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        hintStyle: const TextStyle(color: textTertiary, fontSize: 15),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: textTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: primaryTeal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: error, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: textPrimary,
          disabledBackgroundColor: border,
          disabledForegroundColor: textTertiary,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shadowColor: shadowTint.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryTeal,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border.withValues(alpha: 0.72),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          height: 1.12,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.18,
          letterSpacing: 0,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.28,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.32,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.52, color: textSecondary),
        bodyMedium: TextStyle(fontSize: 14, height: 1.46, color: textSecondary),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: textPrimary,
        ),
      ),
    );
  }
}
