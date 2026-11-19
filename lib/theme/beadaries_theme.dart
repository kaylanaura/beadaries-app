// Backward-compatible reservation theme facade.
// Keep reservation screens aligned with the application's shared AppTheme.

import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';

class BeadariesTheme {
  static const Color creamBackground = AppColors.cream;
  static const Color creamCard = Color(0xFFFFFFFF);
  static const Color sageGreen = AppColors.sage;
  static const Color sageLight = AppColors.sageLight;
  static const Color sageDark = Color(0xFF2F5233);
  static const Color purpleHint = AppColors.purple;
  static const Color purpleLight = AppColors.purpleLight;
  static const Color textDark = AppColors.ink;
  static const Color textMuted = AppColors.muted;

  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: sageGreen,
        primary: sageGreen,
        secondary: purpleHint,
        surface: creamCard,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: creamBackground,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: sageGreen.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: sageGreen.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: purpleHint, width: 1.8),
        ),
      ),
    );
  }
}
