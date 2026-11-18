import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const cream = Color(0xFFFAF6EE);
  static const creamDeep = Color(0xFFF1EADC);
  static const sage = Color(0xFF3F5B42);
  static const sageLight = Color(0xFFE4ECE1);
  static const purple = Color(0xFF7B5EA7);
  static const purpleLight = Color(0xFFEFE8F7);
  static const ink = Color(0xFF2B2F2A);
  static const muted = Color(0xFF8A8F86);
  static const error = Color(0xFFB3473F);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sage,
        primary: AppColors.sage,
        secondary: AppColors.purple,
        surface: AppColors.cream,
        error: AppColors.error,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.poppins().fontFamily,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.poppins(color: AppColors.muted, fontSize: 14),
        errorStyle: GoogleFonts.poppins(color: AppColors.error, fontSize: 12),
        border: _border(AppColors.creamDeep),
        enabledBorder: _border(AppColors.creamDeep),
        focusedBorder: _border(AppColors.purple, width: 1.5),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, width: 1.5),
      ),
    );
  }

  static OutlineInputBorder _border(Color c, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: c, width: width),
      );
}
