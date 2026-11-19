// File: lib/services/ai_recommender_service.dart
// Author: Kayla Binti Mohamad (102641)
// Requirement: FR-AI-01 to FR-AI-03 AI Design Recommender (UI-08) | Branch: feat/fr-ai01-recommender
// Description: The AI service interface and a mock version that works with no internet or API key.

import 'dart:async';
import 'dart:math';

import '../models/ai_recommendation.dart';
import 'reservation_store.dart';

/// Any AI backend must follow this contract.
/// TODO: add GeminiAiRecommenderService (Cloud Function / Firebase AI Logic) when Firebase is ready.
/// The screen only knows this interface, so swapping the service needs no UI change.
abstract class AiRecommenderService {
  /// Returns a design recommendation. May throw if the AI is busy or offline.
  Future<AiRecommendation> recommend(AiPreferences prefs);

  /// FR-AI-03: curated in-stock pieces shown when [recommend] fails.
  AiRecommendation fallback(AiPreferences prefs);
}

/// Mock AI. It builds a design from fixed palettes and matches real products
/// from [ReservationStore], so the demo works without a backend.
class MockAiRecommenderService implements AiRecommenderService {
  /// [simulateOutage] makes [recommend] fail so we can demo the fallback.
  MockAiRecommenderService({
    ReservationStore? store,
    this.simulateOutage = false,
    this.delay = const Duration(milliseconds: 1200),
  }) : _store = store ?? ReservationStore.instance;

  final ReservationStore _store;

  /// When true, every request fails like a timeout.
  bool simulateOutage;

  /// Fake thinking time so the loading indicator is visible.
  final Duration delay;

  /// Bead ideas for each colour aesthetic.
  static const Map<String, List<String>> _palettes = {
    'Cream & Sage': ['Cream freshwater pearl', 'Sage glass bead', 'Gold-tone spacer'],
    'Soft Lavender': ['Lavender glass bead', 'Pearl white seed bead', 'Silver-tone spacer'],
    'Pastel Mix': ['Pink acrylic bead', 'Mint seed bead', 'Pale yellow crystal'],
    'Classic Neutral': ['Ivory pearl', 'Smoky quartz bead', 'Gold-tone charm'],
  };

  @override
  Future<AiRecommendation> recommend(AiPreferences prefs) async {
    await Future<void>.delayed(delay);
    if (simulateOutage) {
      throw TimeoutException('Mock AI outage');
    }

    // Join the bead ideas of all chosen colours (a Set removes duplicates).
    final palette = <String>{
      for (final colour in prefs.selectedColours) ...(_palettes[colour] ?? const <String>[]),
    }.toList();

    final typeWord = prefs.accessoryType == 'Any' ? 'Design' : _singular(prefs.accessoryType);
    final who = prefs.stylingFor == 'Myself' ? 'yourself' : 'your ${prefs.stylingFor.toLowerCase()}';

    return AiRecommendation(
      designTitle: '${prefs.selectedColours.join(' & ')} $typeWord Suite',
      beadPalette: palette,
      stylingNote: 'A soft handmade look for $who. Mix ${palette.first.toLowerCase()} '
          'with the other beads and keep the clasp simple.',
      // Keep the estimate inside the customer's budget.
      estimatedPriceMYR: min(prefs.maxBudgetMYR, 10 + palette.length * 4.0),
      matchedProducts: _matchProducts(prefs),
    );
  }

  @override
  AiRecommendation fallback(AiPreferences prefs) {
    final available = _store.products.where((p) => p.status == 'Available').toList();
    final sameType = available
        .where((p) => prefs.accessoryType == 'Any' || p.category == prefs.accessoryType)
        .toList();
    // If nothing matches the type, show any available pieces instead.
    final picks = (sameType.isNotEmpty ? sameType : available).take(4).toList();

    return AiRecommendation(
      designTitle: 'Handpicked for you',
      beadPalette: const [],
      stylingNote: 'Our AI Stylist is taking a short breather — '
          'here are handpicked pieces matching your style!',
      estimatedPriceMYR: 0,
      matchedProducts: picks,
      isFallback: true,
    );
  }

  /// BR-05: only Available items that are inside the budget (and the chosen type).
  List<BeadProduct> _matchProducts(AiPreferences prefs) {
    return _store.products.where((p) {
      final typeOk = prefs.accessoryType == 'Any' || p.category == prefs.accessoryType;
      return p.status == 'Available' && p.priceMYR <= prefs.maxBudgetMYR && typeOk;
    }).toList();
  }

  /// "Bracelets" becomes "Bracelet", "Phone Charms" becomes "Phone Charm".
  String _singular(String plural) =>
      plural.endsWith('s') ? plural.substring(0, plural.length - 1) : plural;
}
