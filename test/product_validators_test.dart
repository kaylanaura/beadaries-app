// File: product_validators_test.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Unit tests for the product form validators.

import 'package:beadaries_prototype/utils/product_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('name', () {
    test('valid name passes', () {
      expect(ProductValidators.name('Sage Bracelet'), isNull);
    });
    test('empty or spaces only fails', () {
      expect(ProductValidators.name(''), isNotNull);
      expect(ProductValidators.name('   '), isNotNull);
    });
  });

  group('price', () {
    test('valid prices pass', () {
      expect(ProductValidators.price('25.00'), isNull);
      expect(ProductValidators.price('22'), isNull);
    });
    test('price 0 is blocked', () {
      expect(ProductValidators.price('0'), 'Price must be greater than 0');
    });
    test('negative price is blocked', () {
      expect(ProductValidators.price('-5'), isNotNull);
    });
    test('non-numeric price is blocked', () {
      expect(ProductValidators.price('abc'), isNotNull);
    });
    test('3 decimal places is blocked', () {
      expect(ProductValidators.price('12.345'), isNotNull);
    });
    test('empty price is blocked', () {
      expect(ProductValidators.price(''), isNotNull);
    });
  });

  group('image', () {
    test('wrong extension is blocked with the exact message', () {
      expect(ProductValidators.imageFile('photo.gif', 1000),
          'Please upload a JPG/PNG image under 5 MB');
    });
    test('file over 5 MB (6 MB) is blocked', () {
      expect(ProductValidators.imageFile('photo.png', 6 * 1024 * 1024),
          'Please upload a JPG/PNG image under 5 MB');
    });
    test('valid JPG under 5 MB passes (capital letters ok)', () {
      expect(ProductValidators.imageFile('PHOTO.JPG', 1024 * 1024), isNull);
    });
  });
}
