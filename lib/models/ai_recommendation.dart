// File: lib/models/ai_recommendation.dart
// Author: Kayla Binti Mohamad (102641)
// Requirement: FR-AI-01 to FR-AI-04 AI Design Recommender (UI-08) | Branch: feat/fr-ai01-recommender
// Description: Simple data classes for what the customer picks and what the AI stylist returns.

import '../services/reservation_store.dart';

/// Who the accessory is for (shown as chips on the screen).
const List<String> kStylingForOptions = [
  'Myself',
  'Girlfriend',
  'Mom',
  'Daughter',
];

/// Colour aesthetics the customer can pick (more than one is allowed).
const List<String> kColourOptions = [
  'Cream & Sage',
  'Soft Lavender',
  'Pastel Mix',
  'Classic Neutral',
];

/// Accessory types. These names match BeadProduct.category in reservation_store.dart.
const List<String> kAccessoryOptions = [
  'Any',
  'Bracelets',
  'Phone Charms',
  'Keychains',
];

/// What the customer chose on the form.
/// Note: it holds NO personal data (no name, phone or email) so it is PDPA safe (BR-06).
class AiPreferences {
  /// Who the piece is for, for example "Myself".
  final String stylingFor;

  /// Selected colour aesthetics.
  final Set<String> selectedColours;

  /// "Any" or one of the product categories.
  final String accessoryType;

  /// Maximum budget in RM.
  final double maxBudgetMYR;

  /// Creates the preferences object.
  const AiPreferences({
    required this.stylingFor,
    required this.selectedColours,
    required this.accessoryType,
    required this.maxBudgetMYR,
  });

  /// FR-AI-01: at least one style preference is needed before we can generate.
  bool get isValid => selectedColours.isNotEmpty;
}

/// What the AI stylist gives back to the screen.
class AiRecommendation {
  /// Short name of the design, for example "Cream & Sage Bracelet Suite".
  final String designTitle;

  /// List of bead types / colours.
  final List<String> beadPalette;

  /// One or two sentences explaining the styling idea.
  final String stylingNote;

  /// Estimated price in RM (0 for fallback results).
  final double estimatedPriceMYR;

  /// In-stock catalogue pieces that match (BR-05: Available and within budget).
  final List<BeadProduct> matchedProducts;

  /// True when the AI was unavailable and we show curated pieces instead (FR-AI-03).
  final bool isFallback;

  /// Creates a recommendation.
  const AiRecommendation({
    required this.designTitle,
    required this.beadPalette,
    required this.stylingNote,
    required this.estimatedPriceMYR,
    required this.matchedProducts,
    this.isFallback = false,
  });

  /// Text that is copied into the reservation notes (FR-AI-04).
  String get designSummary => '$designTitle (${beadPalette.join(', ')})';
}
