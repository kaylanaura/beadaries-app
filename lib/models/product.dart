// File: product.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Product model for the "products" Firestore collection, plus status and category constants.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Status values used across the whole app.
class ProductStatus {
  static const String available = 'Available';
  static const String pending = 'Pending';
  static const String reserved = 'Reserved';
  static const String soldOut = 'Sold Out';

  /// Only these two can be chosen by the admin in the form.
  static const List<String> editable = [available, soldOut];

  /// BR-01: Pending and Reserved are controlled by the reservation workflow.
  static bool isManagedByReservation(String status) {
    return status == pending || status == reserved;
  }
}

/// Category choices for the dropdown.
class ProductCategory {
  static const String other = 'Other';
  static const List<String> all = ['Bracelet', 'Phone Charm', 'Keychain', other];
}

/// One Beadaries product. Field names match Firestore exactly (teammates read the same collection).
class Product {
  const Product({
    required this.productId,
    required this.name,
    required this.category,
    required this.beadMaterial,
    required this.colorPalette,
    required this.description,
    required this.priceMYR,
    this.imageUrls = const [],
    required this.status,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String productId; // Firestore document id
  final String name;
  final String category;
  final String beadMaterial;
  final String colorPalette;
  final String description;
  final double priceMYR;

  /// Network URLs (http...) or local file paths (mock mode / not yet uploaded).
  final List<String> imageUrls;
  final String status;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  static final NumberFormat _priceFormat =
      NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

  /// Price shown in the UI, for example "RM 25.00".
  String get priceLabel => _priceFormat.format(priceMYR);

  /// Builds a Product from a Firestore document.
  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Product(
      productId: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? ProductCategory.other,
      beadMaterial: data['beadMaterial'] as String? ?? '',
      colorPalette: data['colorPalette'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priceMYR: (data['priceMYR'] as num?)?.toDouble() ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? const []),
      status: data['status'] as String? ?? ProductStatus.available,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  /// Converts a Firestore Timestamp to DateTime (falls back to now if missing).
  static DateTime _toDate(Object? value) {
    return value is Timestamp ? value.toDate() : DateTime.now();
  }

  /// Map to save in Firestore (productId is the document id, so it is not included).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'beadMaterial': beadMaterial,
      'colorPalette': colorPalette,
      'description': description,
      'priceMYR': priceMYR,
      'imageUrls': imageUrls,
      'status': status,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Returns a copy with some fields changed.
  Product copyWith({
    String? productId,
    String? name,
    String? category,
    String? beadMaterial,
    String? colorPalette,
    String? description,
    double? priceMYR,
    List<String>? imageUrls,
    String? status,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      category: category ?? this.category,
      beadMaterial: beadMaterial ?? this.beadMaterial,
      colorPalette: colorPalette ?? this.colorPalette,
      description: description ?? this.description,
      priceMYR: priceMYR ?? this.priceMYR,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}