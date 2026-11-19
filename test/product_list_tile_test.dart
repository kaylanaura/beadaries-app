// File: product_list_tile_test.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Widget test for BR-01: the stock Switch is disabled for Pending and Reserved.

import 'package:beadaries_prototype/models/product.dart';
import 'package:beadaries_prototype/widgets/admin/product_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Builds a sample product with the given status.
  Product sample(String status) {
    final now = DateTime.now();
    return Product(
      productId: 'p1',
      name: 'Test Charm',
      category: 'Phone Charm',
      beadMaterial: 'Glass',
      colorPalette: 'Sage',
      description: '',
      priceMYR: 25,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Shows the tile and returns its Switch widget.
  Future<Switch> pumpTile(WidgetTester tester, String status) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ProductListTile(
          product: sample(status),
          onToggle: (_) {},
          onEdit: () {},
          onArchive: () {},
        ),
      ),
    ));
    return tester.widget<Switch>(find.byType(Switch));
  }

  testWidgets('Switch is disabled for Pending and Reserved, enabled for Available',
      (tester) async {
    expect((await pumpTile(tester, ProductStatus.pending)).onChanged, isNull);
    expect((await pumpTile(tester, ProductStatus.reserved)).onChanged, isNull);
    expect((await pumpTile(tester, ProductStatus.available)).onChanged, isNotNull);
  });
}
