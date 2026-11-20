// File: product_list_tile.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Product card for the admin list (image, details, status pill, stock switch, edit, archive).

import 'package:material_ui/material_ui.dart';

import '../../models/product.dart';
import '../../theme/inventory_colors.dart';
import '../product_image_view.dart';
import 'status_pill.dart';

/// Shows a product image from a URL, data URI, or local file path.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, this.source, this.size = 72});

  /// URL, data URI, local file path, or null / empty for no image.
  final String? source;
  final double size;

  /// Light box with an icon, used when there is no image or it fails to load.
  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      color: InventoryColors.lavenderTint,
      child: const Icon(
        Icons.image_outlined,
        color: InventoryColors.lavenderText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ProductImageView(
        source: source,
        width: size,
        height: size,
        placeholder: _placeholder(),
      ),
    );
  }
}

/// One product card in the admin inventory list.
class ProductListTile extends StatelessWidget {
  const ProductListTile({
    super.key,
    required this.product,
    required this.onToggle,
    required this.onEdit,
    required this.onArchive,
  });

  final Product product;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: InventoryColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: InventoryColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _buildInfoRow(context),
            const SizedBox(height: 8),
            _buildActionRow(context),
          ],
        ),
      ),
    );
  }

  /// Top part: thumbnail, name, category, price, status pill.
  Widget _buildInfoRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImage(
          source: product.imageUrls.isEmpty ? null : product.imageUrls.first,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                product.category,
                style: textTheme.bodySmall?.copyWith(
                  color: InventoryColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.priceLabel,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              StatusPill(status: product.status),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom part: stock switch with helper text, edit and archive buttons.
  Widget _buildActionRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // BR-01: Pending / Reserved are managed by the reservation workflow.
    final locked = ProductStatus.isManagedByReservation(product.status);
    final isAvailable = product.status == ProductStatus.available;

    final stockSwitch = Switch(
      value: isAvailable,
      onChanged: locked ? null : onToggle, // null = disabled
      activeTrackColor: InventoryColors.forestGreen,
    );

    return Row(
      children: [
        locked
            ? Tooltip(message: 'Managed by reservations', child: stockSwitch)
            : stockSwitch,
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            locked
                ? 'Managed by reservations'
                : (isAvailable ? 'In stock' : 'Sold out'),
            style: textTheme.bodySmall?.copyWith(
              color: InventoryColors.textMuted,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Edit product',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Archive product',
          onPressed: onArchive,
          color: InventoryColors.errorRed,
          icon: const Icon(Icons.archive_outlined),
        ),
      ],
    );
  }
}
