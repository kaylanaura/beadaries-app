import 'package:beadaries_prototype/models/product.dart';
import 'package:beadaries_prototype/services/reservation_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inventory products can be reserved without resetting demo locks', () {
    const productId = 'inventory-reservation-test';
    final now = DateTime.utc(2026);
    final product = Product(
      productId: productId,
      name: 'Sage Bracelet',
      category: 'Bracelet',
      beadMaterial: 'Glass beads',
      colorPalette: 'Sage',
      description: 'Handmade bracelet.',
      priceMYR: 25,
      status: ProductStatus.available,
      createdAt: now,
      updatedAt: now,
    );

    final store = ReservationStore.instance;
    final reservationProduct = store.registerInventoryProduct(product);
    reservationProduct.status = ProductStatus.pending;

    final refreshedProduct = store.registerInventoryProduct(
      product.copyWith(name: 'Updated Sage Bracelet'),
    );

    expect(refreshedProduct, same(reservationProduct));
    expect(refreshedProduct.name, 'Updated Sage Bracelet');
    expect(refreshedProduct.status, ProductStatus.pending);
  });
}
