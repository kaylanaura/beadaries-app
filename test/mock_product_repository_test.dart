// File: mock_product_repository_test.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Unit tests for MockProductRepository (add, edit price, toggle status, archive).

import 'package:beadaries_prototype/models/product.dart';
import 'package:beadaries_prototype/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockProductRepository repo;

  setUp(() {
    repo = MockProductRepository(simulatedDelay: Duration.zero);
  });

  tearDown(() => repo.dispose());

  /// Current list (the stream sends the latest list first).
  Future<List<Product>> currentList() => repo.watchProducts().first;

  test(
    'seed data has 8 products: 6 Available, 1 Pending, 1 Reserved',
    () async {
      final list = await currentList();
      expect(list.length, 8);
      expect(list.where((p) => p.status == ProductStatus.available).length, 6);
      expect(list.where((p) => p.status == ProductStatus.pending).length, 1);
      expect(list.where((p) => p.status == ProductStatus.reserved).length, 1);
    },
  );

  test('add creates a product at the top of the list', () async {
    final now = DateTime.now();
    await repo.addProduct(
      Product(
        productId: '',
        name: 'New Bracelet',
        category: 'Bracelet',
        beadMaterial: 'Glass',
        colorPalette: 'Sage',
        description: '',
        priceMYR: 20,
        status: ProductStatus.available,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final list = await currentList();
    expect(list.length, 9);
    expect(list.first.name, 'New Bracelet');
  });

  test('edit price RM 25.00 to RM 22.00', () async {
    final item = (await currentList()).firstWhere((p) => p.priceMYR == 25.00);
    await repo.updateProduct(item.copyWith(priceMYR: 22.00));
    final updated = (await currentList()).firstWhere(
      (p) => p.productId == item.productId,
    );
    expect(updated.priceMYR, 22.00);
    expect(updated.priceLabel, 'RM 22.00');
  });

  test('toggle status Available to Sold Out', () async {
    final item = (await currentList()).firstWhere(
      (p) => p.status == ProductStatus.available,
    );
    await repo.updateStatus(item.productId, ProductStatus.soldOut);
    final updated = (await currentList()).firstWhere(
      (p) => p.productId == item.productId,
    );
    expect(updated.status, ProductStatus.soldOut);
  });

  test('archive hides the item from the list', () async {
    final item = (await currentList()).first;
    await repo.archiveProduct(item.productId);
    final list = await currentList();
    expect(list.any((p) => p.productId == item.productId), isFalse);
    expect(list.length, 7);
  });
}
