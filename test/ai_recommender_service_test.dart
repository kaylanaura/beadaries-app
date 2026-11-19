// File: test/ai_recommender_service_test.dart
// Author: Kayla Binti Mohamad (102641)
// Requirement: FR-AI-01 to FR-AI-03, BR-05 | Branch: feat/fr-ai01-recommender
// Description: Unit tests for MockAiRecommenderService (matching rules, budget, fallback).

import 'dart:async';

import 'package:beadaries_prototype/models/ai_recommendation.dart';
import 'package:beadaries_prototype/services/ai_recommender_service.dart';
import 'package:flutter_test/flutter_test.dart';

AiPreferences _prefs({String type = 'Any', double budget = 60}) => AiPreferences(
      stylingFor: 'Myself',
      selectedColours: const {'Cream & Sage'},
      accessoryType: type,
      maxBudgetMYR: budget,
    );

void main() {
  final service = MockAiRecommenderService(delay: Duration.zero);

  test('preferences are invalid when no colour is picked', () {
    const empty = AiPreferences(
      stylingFor: 'Myself',
      selectedColours: {},
      accessoryType: 'Any',
      maxBudgetMYR: 30,
    );
    expect(empty.isValid, isFalse);
  });

  test('recommendation has a title and bead palette', () async {
    final result = await service.recommend(_prefs());
    expect(result.designTitle, contains('Cream & Sage'));
    expect(result.beadPalette, isNotEmpty);
    expect(result.isFallback, isFalse);
  });

  test('BR-05: only Available products are matched', () async {
    final result = await service.recommend(_prefs());
    expect(result.matchedProducts.every((p) => p.status == 'Available'), isTrue);
  });

  test('BR-05: products above the budget are left out', () async {
    final result = await service.recommend(_prefs(budget: 20));
    expect(result.matchedProducts.every((p) => p.priceMYR <= 20), isTrue);
  });

  test('accessory type filters the matched products', () async {
    final result = await service.recommend(_prefs(type: 'Bracelets'));
    expect(result.matchedProducts.every((p) => p.category == 'Bracelets'), isTrue);
  });

  test('estimated price never goes above the budget', () async {
    final result = await service.recommend(_prefs(budget: 12));
    expect(result.estimatedPriceMYR, lessThanOrEqualTo(12));
  });

  test('FR-AI-03: outage throws so the screen can use the fallback', () async {
    final broken = MockAiRecommenderService(delay: Duration.zero, simulateOutage: true);
    expect(broken.recommend(_prefs()), throwsA(isA<TimeoutException>()));
  });

  test('FR-AI-03: fallback shows at most 4 Available products', () {
    final result = service.fallback(_prefs());
    expect(result.isFallback, isTrue);
    expect(result.matchedProducts.length, lessThanOrEqualTo(4));
    expect(result.matchedProducts.every((p) => p.status == 'Available'), isTrue);
  });
}
