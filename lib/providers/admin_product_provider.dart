// File: admin_product_provider.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: ChangeNotifier for the admin product list: live data, search, counts, save, toggle, archive.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

// TODO: switch useMockData to false when Firebase is connected (Kayla's setup)
const bool useMockData = true;

/// State for the Admin Inventory tab. The shell can also read the counts for its KPI strip.
class AdminProductProvider extends ChangeNotifier {
  /// Pass a repository for testing; otherwise the useMockData flag decides.
  AdminProductProvider({ProductRepository? repository})
    : _repository =
          repository ??
          (useMockData
              ? MockProductRepository()
              : FirestoreProductRepository()) {
    _listenToProducts();
  }

  final ProductRepository _repository;
  StreamSubscription<List<Product>>? _subscription;

  List<Product> _products = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchText = '';

  /// All non-archived products (not filtered by search).
  List<Product> get allProducts => _products;

  /// Products after applying the search text (case-insensitive, by name).
  List<Product> get products {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) {
      return _products;
    }
    return _products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get searchText => _searchText;

  /// Counts for the shell's KPI strip (archived items are never in the list).
  int get availableCount => _countByStatus(ProductStatus.available);
  int get pendingCount => _countByStatus(ProductStatus.pending);
  int get reservedCount => _countByStatus(ProductStatus.reserved);

  /// Counts live products with the given status.
  int _countByStatus(String status) {
    return _products.where((p) => !p.isArchived && p.status == status).length;
  }

  /// Starts listening to the real-time product stream.
  void _listenToProducts() {
    _subscription = _repository.watchProducts().listen(
      (list) {
        _products = list;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Could not load products. Please try again.';
        notifyListeners();
      },
    );
  }

  /// Updates the search text and refreshes the list.
  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  /// Adds (isNew = true) or edits a product. Returns true if it worked.
  Future<bool> saveProduct(Product product, {required bool isNew}) async {
    _isSaving = true; // the form disables Save and shows a spinner
    notifyListeners();
    try {
      if (isNew) {
        await _repository.addProduct(product);
      } else {
        await _repository.updateProduct(product);
      }
      return true;
    } catch (_) {
      return false; // the form shows the failure SnackBar
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Switches Available <-> Sold Out. Returns true if it worked.
  Future<bool> toggleStock(Product product) async {
    // BR-01: Pending / Reserved are controlled by the reservation workflow.
    if (ProductStatus.isManagedByReservation(product.status)) {
      return false;
    }
    final newStatus = product.status == ProductStatus.available
        ? ProductStatus.soldOut
        : ProductStatus.available;
    try {
      await _repository.updateStatus(product.productId, newStatus);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Soft delete: sets isArchived = true. Returns true if it worked.
  Future<bool> archiveProduct(String productId) async {
    try {
      await _repository.archiveProduct(productId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
