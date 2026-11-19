// File: product_validators.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Static validators for the product form (SRS FR-09). Return null when valid.

/// Validation rules for the Add/Edit Product form.
class ProductValidators {
  /// Maximum image size: 5 MB.
  static const int maxImageBytes = 5 * 1024 * 1024;

  /// Exact error text required by the SRS.
  static const String imageError = 'Please upload a JPG/PNG image under 5 MB';

  /// Name: required, not empty after trim.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the product name';
    }
    return null;
  }

  /// Category: required.
  static String? category(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please choose a category';
    }
    return null;
  }

  /// Status: required.
  static String? status(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please choose a status';
    }
    return null;
  }

  /// Price: required, valid number, more than 0, max 2 decimal places.
  static String? price(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter the price';
    }
    // Only digits with an optional minus and decimal part are accepted as a number.
    if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(text)) {
      return 'Price must be a valid number';
    }
    if (double.parse(text) <= 0) {
      return 'Price must be greater than 0';
    }
    // At most 2 digits after the decimal point.
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
      return 'Price can have at most 2 decimal places';
    }
    return null;
  }

  /// True if the file name ends with .jpg, .jpeg or .png (any letter case).
  static bool isValidImageExtension(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  /// True if the size is under 5 MB.
  static bool isValidImageSize(int sizeInBytes) {
    return sizeInBytes < maxImageBytes;
  }

  /// Checks one image file. Returns the SRS error text, or null if the file is fine.
  static String? imageFile(String fileName, int sizeInBytes) {
    if (!isValidImageExtension(fileName) || !isValidImageSize(sizeInBytes)) {
      return imageError;
    }
    return null;
  }
}
