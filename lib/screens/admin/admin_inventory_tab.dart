// File: admin_inventory_tab.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Content of the "Inventory (FR-09)" tab: search, Add Product button and the product list.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/admin_product_provider.dart';
import '../../theme/inventory_colors.dart';
import '../../widgets/admin/product_form_sheet.dart';
import '../../widgets/admin/product_list_tile.dart';

/// Self-contained inventory tab. The dashboard shell places it inside its tab view.
/// Needs AdminProductProvider above MaterialApp.
class AdminInventoryTab extends StatelessWidget {
  const AdminInventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              // Search by product name
              TextField(
                onChanged: provider.setSearchText,
                decoration: const InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ProductFormSheet.show(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ),
        ),
        Expanded(child: _buildList(context, provider)),
      ],
    );
  }

  /// Loading, error, empty or the real list.
  Widget _buildList(BuildContext context, AdminProductProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return _centerMessage(context, provider.errorMessage!);
    }
    if (provider.allProducts.isEmpty) {
      return _centerMessage(
        context,
        'No products yet. Tap + Add Product to add your first bead design.',
      );
    }
    final products = provider.products;
    if (products.isEmpty) {
      return _centerMessage(context, 'No products match your search.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListTile(
          product: product,
          onToggle: (_) => _toggleStock(context, product),
          onEdit: () => ProductFormSheet.show(context, product: product),
          onArchive: () => _confirmArchive(context, product),
        );
      },
    );
  }

  /// Centered grey message used for empty and error states.
  Widget _centerMessage(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: InventoryColors.textMuted),
        ),
      ),
    );
  }

  /// Switch Available <-> Sold Out right away.
  Future<void> _toggleStock(BuildContext context, Product product) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<AdminProductProvider>().toggleStock(product);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not change stock. Please try again.'),
        ),
      );
    }
  }

  /// Asks for confirmation, then archives (soft delete).
  Future<void> _confirmArchive(BuildContext context, Product product) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<AdminProductProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: InventoryColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Archive this product?'),
        content: const Text('It will be hidden from the catalogue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: InventoryColors.errorRed,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final ok = await provider.archiveProduct(product.productId);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Product archived'
              : 'Could not archive product. Please try again.',
        ),
      ),
    );
  }
}
