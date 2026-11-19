// File: product_service.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: ProductRepository (abstract) with a Firestore version and an in-memory Mock version for Demo 1.

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product.dart';

/// What the provider needs from the data layer. Both implementations follow this.
/// Note: product.imageUrls may mix http URLs (already uploaded) and local file paths (new).
abstract class ProductRepository {
  /// Live list of NON-archived products, newest first.
  Stream<List<Product>> watchProducts();

  /// Creates a new product (sets createdAt and updatedAt).
  Future<void> addProduct(Product product);

  /// Updates an existing product (sets updatedAt).
  Future<void> updateProduct(Product product);

  /// Changes only the status (used by the stock switch).
  Future<void> updateStatus(String productId, String status);

  /// Soft delete: sets isArchived = true. The document is never deleted.
  Future<void> archiveProduct(String productId);

  /// Releases resources (streams).
  void dispose();
}

/// Real implementation using Cloud Firestore and Firebase Storage.
class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// The "products" collection.
  CollectionReference<Map<String, dynamic>> get _products => _firestore.collection('products');

  @override
  Stream<List<Product>> watchProducts() {
    // Order by createdAt only (no composite index needed), then hide archived items here.
    return _products.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) =>
              snapshot.docs.map(Product.fromFirestore).where((p) => !p.isArchived).toList(),
        );
  }

  @override
  Future<void> addProduct(Product product) async {
    final docRef = _products.doc(); // new document id
    final urls = await _uploadImages(docRef.id, product.imageUrls);
    final now = DateTime.now();
    final newProduct = product.copyWith(
      productId: docRef.id,
      imageUrls: urls,
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(newProduct.toMap());
  }

  @override
  Future<void> updateProduct(Product product) async {
    final urls = await _uploadImages(product.productId, product.imageUrls);
    final updated = product.copyWith(imageUrls: urls, updatedAt: DateTime.now());
    // Do not overwrite createdAt when editing.
    final data = updated.toMap()..remove('createdAt');
    await _products.doc(product.productId).update(data);
  }

  @override
  Future<void> updateStatus(String productId, String status) async {
    await _products.doc(productId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> archiveProduct(String productId) async {
    await _products.doc(productId).update({
      'isArchived': true,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Uploads local files to products/{productId}/ and returns all download URLs.
  /// Items that are already http URLs are kept as they are.
  Future<List<String>> _uploadImages(String productId, List<String> sources) async {
    final urls = <String>[];
    for (var i = 0; i < sources.length; i++) {
      final source = sources[i];
      if (source.startsWith('http')) {
        urls.add(source);
        continue;
      }
      final extension = source.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.$extension';
      final ref = _storage.ref('products/$productId/$fileName');
      final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
      await ref.putFile(File(source), SettableMetadata(contentType: contentType));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  @override
  void dispose() {}
}

/// In-memory implementation for the partially functional Demo 1 (no Firebase needed).
class MockProductRepository implements ProductRepository {
  MockProductRepository({this.simulatedDelay = const Duration(milliseconds: 400)})
      : _products = _buildSeedProducts();

  /// Fake waiting time so the "saving" spinner is visible. Tests use Duration.zero.
  final Duration simulatedDelay;

  final List<Product> _products;
  final StreamController<List<Product>> _controller =
      StreamController<List<Product>>.broadcast();
  int _nextId = 1;

  @override
  Stream<List<Product>> watchProducts() async* {
    yield _visibleProducts(); // first value right away
    yield* _controller.stream; // then every change
  }

  @override
  Future<void> addProduct(Product product) async {
    await Future<void>.delayed(simulatedDelay);
    final now = DateTime.now();
    // In mock mode the local file paths are simply kept (no upload).
    _products.add(product.copyWith(
      productId: 'mock-${_nextId++}',
      createdAt: now,
      updatedAt: now,
    ));
    _emit();
  }

  @override
  Future<void> updateProduct(Product product) async {
    await Future<void>.delayed(simulatedDelay);
    _replace(product.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<void> updateStatus(String productId, String status) async {
    final product = _find(productId);
    _replace(product.copyWith(status: status, updatedAt: DateTime.now()));
  }

  @override
  Future<void> archiveProduct(String productId) async {
    final product = _find(productId);
    _replace(product.copyWith(isArchived: true, updatedAt: DateTime.now()));
  }

  /// Finds a product by id (throws if missing, the provider catches it).
  Product _find(String productId) {
    return _products.firstWhere((p) => p.productId == productId);
  }

  /// Replaces a product in the list and tells listeners.
  void _replace(Product updated) {
    final index = _products.indexWhere((p) => p.productId == updated.productId);
    if (index == -1) {
      throw StateError('Product not found');
    }
    _products[index] = updated;
    _emit();
  }

  /// Non-archived products, newest first.
  List<Product> _visibleProducts() {
    final visible = _products.where((p) => !p.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(visible);
  }

  /// Sends the latest list to the stream.
  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(_visibleProducts());
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// 8 sample products: 6 Available, 1 Pending, 1 Reserved. Smaller n = newer.
List<Product> _buildSeedProducts() {
  return [
    _seed(1, 'Wisteria Charm Bag Chain', ProductCategory.all[1], 'Glass beads, pearls',
        'Lavender, Cream', 42.00, ProductStatus.pending),
    _seed(2, 'Lilac Glass Flower Bracelet', ProductCategory.all[0], 'Glass flower beads',
        'Lilac, Lavender', 30.00, ProductStatus.reserved),
    _seed(3, 'Sage Garden Bead Bracelet', ProductCategory.all[0], 'Seed beads, glass beads',
        'Cream, Sage', 25.00, ProductStatus.available),
    _seed(4, 'Cream Pearl Phone Charm', ProductCategory.all[1], 'Faux pearls',
        'Cream, Gold', 18.00, ProductStatus.available),
    _seed(5, 'Lavender Daisy Keychain', ProductCategory.all[2], 'Acrylic daisy beads',
        'Lavender, White', 15.00, ProductStatus.available),
    _seed(6, 'Mint Leaf Beaded Keychain', ProductCategory.all[2], 'Glass beads',
        'Sage, Mint', 12.00, ProductStatus.available),
    _seed(7, 'Starry Night Bead Bracelet', ProductCategory.all[0], 'Crystal beads',
        'Navy, Silver', 28.00, ProductStatus.available),
    _seed(8, 'Lemon Blossom Phone Strap', ProductCategory.all[1], 'Acrylic beads',
        'Yellow, Cream', 22.00, ProductStatus.available),
  ];
}

/// Builds one seed product. No images, so the UI shows the placeholder icon.
Product _seed(int n, String name, String category, String material, String palette,
    double price, String status) {
  final created = DateTime.now().subtract(Duration(hours: n));
  return Product(
    productId: 'seed-$n',
    name: name,
    category: category,
    beadMaterial: material,
    colorPalette: palette,
    description: 'Handmade by Beadaries.',
    priceMYR: price,
    status: status,
    createdAt: created,
    updatedAt: created,
  );
}