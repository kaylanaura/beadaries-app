// cream background, sage green primary, hint of purple accent, poppins font

import 'package:material_ui/material_ui.dart';

class BeadariesTheme {
  // Brand Palette: Cream, Sage Green & Hint of Purple
  static const Color creamBackground = Color(0xFFFAF7F0);
  static const Color creamCard = Color(0xFFFFFFFF);
  static const Color sageGreen = Color(0xFF6B8E78);
  static const Color sageLight = Color(0xFFE6EFE9);
  static const Color sageDark = Color(0xFF4A6B56);
  static const Color purpleHint = Color(0xFF7E6899);
  static const Color purpleLight = Color(0xFFF2ECF8);
  static const Color textDark = Color(0xFF2B2D2C);
  static const Color textMuted = Color(0xFF6E7571);

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
