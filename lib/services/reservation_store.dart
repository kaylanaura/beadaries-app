// Handles FR-04 Reference ID BDR-2026-XXXX
// Handles FR-05 Atomic Single-Stock Lock (BR-01)
// Handles FR-06 Track Reservation Status via Reference ID
// Handles FR-07 Admin Approve or Reject (BR-02: Auto-release stock if rejected)
// A simplified in-memory store for demonstration purposes.

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/product.dart';

class BeadProduct {
  String id;
  String name;
  String category;
  String beadMaterial;
  double priceMYR;
  String status; // 'Available', 'Pending', 'Reserved', 'Sold Out'

  BeadProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.beadMaterial,
    required this.priceMYR,
    required this.status,
  });
}

class ReservationModel {
  final String referenceId; // e.g., BDR-2026-4821
  final String productId;
  final String productName;
  final double priceMYR;
  final String customerName;
  final String customerPhone;
  final String fulfillmentMethod; // 'Campus Pickup' or 'Postage'
  final String customNotes;
  String status; // 'Pending', 'Approved', 'Rejected'
  String adminRemarks;
  final DateTime createdAt;

  ReservationModel({
    required this.referenceId,
    required this.productId,
    required this.productName,
    required this.priceMYR,
    required this.customerName,
    required this.customerPhone,
    required this.fulfillmentMethod,
    required this.customNotes,
    required this.status,
    this.adminRemarks = '',
    required this.createdAt,
  });
}

/// Shared state implementing FR-04, FR-05 (Atomic Lock), FR-06, and FR-07
class ReservationStore extends ChangeNotifier {
  static final ReservationStore instance = ReservationStore._internal();
  ReservationStore._internal();

  bool _isTransactionLocked = false;

  final List<BeadProduct> products = [
    BeadProduct(
      id: 'PRD-001',
      name: 'Sage & Pearl Blossom Bracelet',
      category: 'Bracelets',
      beadMaterial: 'Freshwater Pearl & Glass Seed Beads',
      priceMYR: 25.00,
      status: 'Available',
    ),
    BeadProduct(
      id: 'PRD-002',
      name: 'Lavender Mist Phone Charm',
      category: 'Phone Charms',
      beadMaterial: 'Acrylic Crystal & Pastel Beads',
      priceMYR: 18.00,
      status: 'Available',
    ),
    BeadProduct(
      id: 'PRD-003',
      name: 'Cream Daisy Coquette Keychain',
      category: 'Keychains',
      beadMaterial: 'Miyuki Delica & Alloy Charm',
      priceMYR: 15.00,
      status: 'Pending',
    ),
  ];

  final List<ReservationModel> reservations = [
    ReservationModel(
      referenceId: 'BDR-2026-1042',
      productId: 'PRD-003',
      productName: 'Cream Daisy Coquette Keychain',
      priceMYR: 15.00,
      customerName: 'Aina Sofea',
      customerPhone: '011-23456789',
      fulfillmentMethod: 'Campus Pickup',
      customNotes: 'Gift wrap please (purple ribbon if available)',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  BeadProduct registerInventoryProduct(Product product) {
    final existingIndex = products.indexWhere(
      (item) => item.id == product.productId,
    );
    if (existingIndex >= 0) {
      final existing = products[existingIndex];
      existing
        ..name = product.name
        ..category = product.category
        ..beadMaterial = product.beadMaterial
        ..priceMYR = product.priceMYR;
      if (existing.status != 'Pending' && existing.status != 'Reserved') {
        existing.status = product.status;
      }
      return existing;
    }

    final inventoryProduct = BeadProduct(
      id: product.productId,
      name: product.name,
      category: product.category,
      beadMaterial: product.beadMaterial,
      priceMYR: product.priceMYR,
      status: product.status,
    );
    products.add(inventoryProduct);
    notifyListeners();
    return inventoryProduct;
  }

  /// FR-04 & FR-05: Submit reservation with Atomic Single-Stock Lock (BR-01)
  Future<ReservationModel> submitReservation({
    required String productId,
    required String customerName,
    required String customerPhone,
    required String fulfillmentMethod,
    String customNotes = '',
  }) async {
    // FR-05: Atomic lock check to prevent double-booking one-of-one items
    if (_isTransactionLocked) {
      throw Exception('System busy. Please try again in a moment.');
    }
    _isTransactionLocked = true;

    try {
      await Future.delayed(
        const Duration(milliseconds: 350),
      ); // Simulate Firestore transaction
      final product = products.firstWhere((p) => p.id == productId);

      if (product.status != 'Available') {
        throw Exception(
          'Sorry, this piece was just reserved by another customer.',
        );
      }

      // Atomic transition: lock product to 'Pending'
      product.status = 'Pending';

      final randomDigits = 1000 + Random().nextInt(9000);
      final refId = 'BDR-2026-$randomDigits';

      final newReservation = ReservationModel(
        referenceId: refId,
        productId: product.id,
        productName: product.name,
        priceMYR: product.priceMYR,
        customerName: customerName.trim(),
        customerPhone: customerPhone.trim(),
        fulfillmentMethod: fulfillmentMethod,
        customNotes: customNotes.trim(),
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      reservations.insert(0, newReservation);
      notifyListeners();
      return newReservation;
    } finally {
      _isTransactionLocked = false;
    }
  }

  /// FR-06: Track reservation status via Reference ID
  ReservationModel? findByReferenceId(String refId) {
    final cleaned = refId.trim().toUpperCase();
    try {
      return reservations.firstWhere(
        (r) => r.referenceId.toUpperCase() == cleaned,
      );
    } catch (_) {
      return null;
    }
  }

  /// FR-07: Admin Approve or Reject (BR-02: Auto-release stock if rejected)
  void reviewReservation({
    required String referenceId,
    required bool isApproved,
    String remarks = '',
  }) {
    final res = reservations.firstWhere((r) => r.referenceId == referenceId);
    final product = products.firstWhere((p) => p.id == res.productId);

    if (isApproved) {
      res.status = 'Approved';
      product.status = 'Reserved';
    } else {
      res.status = 'Rejected';
      product.status = 'Available'; // BR-02: Automatic inventory release
    }

    res.adminRemarks = remarks.trim();
    notifyListeners();
  }
}
