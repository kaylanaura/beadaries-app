// File: status_pill.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Small rounded pill with a leading dot that shows a product status.

import 'package:material_ui/material_ui.dart';

import '../../models/product.dart';
import '../../theme/inventory_colors.dart';

/// Pill such as "• Available", coloured by status.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  /// Background colour for the status.
  Color get _background {
    switch (status) {
      case ProductStatus.available:
        return InventoryColors.sageTint;
      case ProductStatus.pending:
        return InventoryColors.amberTint;
      case ProductStatus.reserved:
        return InventoryColors.lavenderTint;
      default:
        return InventoryColors.soldOutBg;
    }
  }

  /// Text and dot colour for the status.
  Color get _foreground {
    switch (status) {
      case ProductStatus.available:
        return InventoryColors.forestGreen;
      case ProductStatus.pending:
        return InventoryColors.amberText;
      case ProductStatus.reserved:
        return InventoryColors.lavenderText;
      default:
        return InventoryColors.soldOutText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: _background,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: _foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
