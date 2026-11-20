// File: catalogue_screen.dart
// Author: Amreen Mustaqeem Bin Aslan (103308)
// Requirement: FR-02 Product Catalogue
// Description: Displays handmade products with search, category filtering,
// pricing, availability status, and navigation to product details.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/admin_product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image_view.dart';
import 'product_details_screen.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Bracelet',
    'Phone Charm',
    'Keychain',
    'Other',
  ];

  List<Product> _filteredProducts(List<Product> allProducts) {
    return allProducts.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;

      final matchesSearch = product.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<AdminProductProvider>();
    final products = _filteredProducts(productProvider.allProducts);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Catalogue',
          style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.w700),
        ),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.errorMessage != null
          ? Center(child: Text(productProvider.errorMessage!))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find your favourite handmade pieces',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Made with love, just for you.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 18),

                  // Search bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search accessories...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category filters
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final selected = category == _selectedCategory;

                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          selectedColor: AppColors.sageLight,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected ? AppColors.sage : AppColors.muted,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    '${products.length} products',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Catalogue grid
                  Expanded(
                    child: products.isEmpty
                        ? const Center(child: Text('No products found.'))
                        : GridView.builder(
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.68,
                                ),
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return _ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        product: product,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.status == ProductStatus.available;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image / placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.sageLight,
                child: ProductImageView(
                  source: product.imageUrls.firstOrNull,
                  fit: BoxFit.cover,
                  placeholder: const Icon(
                    Icons.auto_awesome,
                    size: 42,
                    color: AppColors.sage,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.priceLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.sage,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.sageLight
                          : AppColors.creamDeep,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isAvailable ? AppColors.sage : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
