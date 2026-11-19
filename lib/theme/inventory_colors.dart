// File: inventory_colors.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Colour constants used only by the Admin Inventory tab (kept separate so the team's AppColors is not changed).
// TODO: merge these into the team theme when the team agrees on one palette.

import 'package:material_ui/material_ui.dart';

/// Colours for the Admin Inventory tab. Never hardcode colours in widgets.
class InventoryColors {
  static const Color cream = Color(0xFFFAF7F2);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderSoft = Color(0xFFE9E3D8);
  static const Color forestGreen = Color(0xFF2F5233); // buttons and main text
  static const Color sageTint = Color(0xFFE4EDDD); // Available background
  static const Color amberText = Color(0xFFB7791F);
  static const Color amberTint = Color(0xFFFFF3D6); // Pending background
  static const Color lavenderText = Color(0xFF6B5B95);
  static const Color lavenderTint = Color(0xFFEFEBF5); // Reserved background
  static const Color soldOutBg = Color(0xFFECECEC);
  static const Color soldOutText = Color(0xFF6E6E6E);
  static const Color errorRed = Color(0xFFC0392B);
  static const Color errorTint = Color(0xFFFDECEC);
  static const Color textMuted = Color(0xFF6F7A6C);
}
