// File: product_details_screen.dart
// Author: Amreen Mustaqeem Bin Aslan (103308)
// Requirement: FR-03 Product Details
// Description: Displays detailed information about a selected handmade
// product, including images, description, price, status, and specifications.



import 'package:flutter/material.dart';



import '../../models/product.dart';
import '../../theme/app_theme.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.status == ProductStatus.available;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: AppColors.sage,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            SizedBox(
              height: 320,
              width: double.infinity,
              child: product.imageUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: product.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          product.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _imagePlaceholder();
                          },
                        );
                      },
                    )
                  : _imagePlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Text(
                    product.priceLabel,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sage,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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
                        color: isAvailable
                            ? AppColors.sage
                            : AppColors.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Divider(),

                  // Product description
                  const Text(
                    'About this piece',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'A handmade accessory carefully crafted with love.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product specifications
                  const Text(
                    'Product Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _detailRow('Category', product.category),
                  _detailRow('Bead Material', product.beadMaterial),
                  _detailRow('Color Palette', product.colorPalette),

                  const SizedBox(height: 28),

                  // Reserve button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isAvailable
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Reservation feature will be connected next.',
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sage,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.muted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isAvailable ? 'Reserve This Item' : 'Not Available',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.sageLight,
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          size: 64,
          color: AppColors.sage,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}