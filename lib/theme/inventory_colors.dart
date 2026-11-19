// File: inventory_colors.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Colour constants used only by the Admin Inventory tab (kept separate so the team's AppColors is not changed).
import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';

/// Colours for the Admin Inventory tab. Never hardcode colours in widgets.
class InventoryColors {
  static const Color cream = AppColors.cream;
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderSoft = Color(0xFFE9E3D8);
  static const Color forestGreen = AppColors.sage;
  static const Color sageTint = AppColors.sageLight;
  static const Color amberText = Color(0xFFB7791F);
  static const Color amberTint = Color(0xFFFFF3D6); // Pending background
  static const Color lavenderText = AppColors.purple;
  static const Color lavenderTint = AppColors.purpleLight;
  static const Color soldOutBg = Color(0xFFECECEC);
  static const Color soldOutText = Color(0xFF6E6E6E);
  static const Color errorRed = AppColors.error;
  static const Color errorTint = Color(0xFFFDECEC);
  static const Color textMuted = AppColors.muted;
}
