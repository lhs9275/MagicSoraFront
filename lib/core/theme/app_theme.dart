import 'package:flutter/material.dart';

/// Flip7 문서의 레트로 게임 감성을 앱 전체에 입히는 기본 테마다.
class AppTheme {
  const AppTheme._();

  static const primaryTeal = Color(0xFF2BA8A2);
  static const primaryLight = Color(0xFF3CC4BD);
  static const primaryDark = Color(0xFF1E8C86);
  static const primaryBg = Color(0xFFE8F6F5);
  static const accentGold = Color(0xFFFFD23F);
  static const accentLight = Color(0xFFFFE47A);
  static const accentDark = Color(0xFFE6B800);
  static const coral = Color(0xFFEF6C4A);
  static const coralLight = Color(0xFFFF8A6A);
  static const coralDark = Color(0xFFD45233);
  static const cream = Color(0xFFFFF8E7);
  static const skyBlue = Color(0xFF5DADE2);
  static const surfaceBase = Color(0xFFEFF8F7);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const success = Color(0xFF27AE60);
  static const error = Color(0xFFE74C3C);
  static const textPrimary = Color(0xFF173D3A);
  static const textSecondary = Color(0xFF5D716E);
  static const border = Color(0xFFD6ECEA);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      primary: primaryTeal,
      secondary: accentGold,
      surface: surfaceCard,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceBase,
      fontFamilyFallback: const [
        'Apple SD Gothic Neo',
        'Noto Sans KR',
        'Roboto',
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceBase,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        hintStyle: const TextStyle(color: Color(0xFF9BA9A6), fontSize: 16),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          disabledBackgroundColor: const Color(0xFFE7DFBF),
          disabledForegroundColor: const Color(0xFF8D8468),
          elevation: 0,
          minimumSize: const Size.fromHeight(58),
          shadowColor: accentGold.withValues(alpha: 0.38),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          height: 1.22,
          letterSpacing: 1.2,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: textSecondary),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: textSecondary),
      ),
    );
  }
}
