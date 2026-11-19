// File: lib/screens/customer/ai_recommender_screen.dart
// Author: Kayla Binti Mohamad (102641)
// Requirement: FR-AI-01 to FR-AI-04 AI Design Recommender (UI-08) | Branch: feat/fr-ai01-recommender
// Description: Colour/style picker and AI result card with fallback, feedback and "Use in Reservation".

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/ai_recommendation.dart';
import '../../services/ai_recommender_service.dart';
import '../../services/reservation_store.dart';
import '../../theme/app_theme.dart';

/// UI-08 screen. Self-contained so the navigation owner (Amreen) can place it in a tab.
class AiRecommenderScreen extends StatefulWidget {
  /// [service] defaults to the mock AI. [onUseInReservation] is called by FR-AI-04's button.
  const AiRecommenderScreen({super.key, this.service, this.onUseInReservation});

  /// AI backend to use (mock by default).
  final AiRecommenderService? service;

  /// Lets the shell open the reservation form with this design (FR-AI-04).
  final ValueChanged<AiRecommendation>? onUseInReservation;

  @override
  State<AiRecommenderScreen> createState() => _AiRecommenderScreenState();
}

class _AiRecommenderScreenState extends State<AiRecommenderScreen> {
  /// NFR-AI-02: show the fallback if the AI is slower than 5 seconds.
  static const Duration _timeout = Duration(seconds: 5);

  /// NFR-AI-03: at most 10 requests per hour.
  static const int _maxRequestsPerHour = 10;

  late final AiRecommenderService _service = widget.service ?? MockAiRecommenderService();

  String _stylingFor = kStylingForOptions.first;
  final Set<String> _colours = {kColourOptions.first};
  String _accessory = kAccessoryOptions.first;
  double _budget = 35;

  bool _loading = false;
  String? _validationError;
  AiRecommendation? _result;
  int _feedback = 0; // 0 = none, +1 = thumbs up, -1 = thumbs down
  final List<DateTime> _requestTimes = [];

  /// Builds the preferences object from the current form values.
  AiPreferences get _prefs => AiPreferences(
        stylingFor: _stylingFor,
        selectedColours: Set<String>.of(_colours),
        accessoryType: _accessory,
        maxBudgetMYR: _budget,
      );

  /// FR-AI-01: validate, call the AI, and fall back if it fails (FR-AI-03).
  Future<void> _generate() async {
    final prefs = _prefs;
    if (!prefs.isValid) {
      setState(() => _validationError = 'Please pick at least one colour aesthetic.');
      return;
    }
    if (_isRateLimited()) {
      _showSnack('You have reached 10 designs this hour. Please try again later.');
      return;
    }

    setState(() {
      _validationError = null;
      _loading = true;
    });

    AiRecommendation result;
    try {
      result = await _service.recommend(prefs).timeout(_timeout);
    } catch (_) {
      // Any error or timeout: never crash, show curated pieces instead.
      result = _service.fallback(prefs);
    }

    if (!mounted) return;
    setState(() {
      _result = result;
      _feedback = 0;
      _loading = false;
    });
  }

  /// Keeps only the last hour of requests and checks the limit.
  bool _isRateLimited() {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    _requestTimes.removeWhere((t) => t.isBefore(oneHourAgo));
    if (_requestTimes.length >= _maxRequestsPerHour) return true;
    _requestTimes.add(DateTime.now());
    return false;
  }

  /// FR-AI-04: one vote per result. TODO: save feedbackRating to Firestore later.
  void _vote(int value) {
    if (_feedback != 0) return;
    setState(() => _feedback = value);
  }

  /// FR-AI-04: hand the design to the shell, or show a hint if it is not connected yet.
  void _useInReservation(AiRecommendation result) {
    final callback = widget.onUseInReservation;
    if (callback != null) {
      callback(result);
    } else {
      _showSnack('Design notes ready: ${result.designSummary}');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'AI Bead Stylist',
          style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'AI STYLIST • PDPA SAFE',
            style: TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          _buildFormCard(),
          const SizedBox(height: 16),
          if (result != null) _buildResultCard(result),
        ],
      ),
    );
  }

  /// Lavender card with the colour/style picker.
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purpleLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.creamDeep),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Styling For'),
          _chips(
            options: kStylingForOptions,
            isSelected: (o) => _stylingFor == o,
            onTap: (o) => setState(() => _stylingFor = o),
          ),
          const SizedBox(height: 16),
          _label('Color Aesthetic (pick one or more)'),
          _chips(
            options: kColourOptions,
            isSelected: _colours.contains,
            onTap: (o) => setState(() {
              _colours.contains(o) ? _colours.remove(o) : _colours.add(o);
              _validationError = null;
            }),
          ),
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _validationError!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          _label('Accessory Type'),
          _chips(
            options: kAccessoryOptions,
            isSelected: (o) => _accessory == o,
            onTap: (o) => setState(() => _accessory = o),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _label('Max Budget (MYR)')),
              Text(
                'RM ${_budget.round()}.00',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.purple),
              ),
            ],
          ),
          Slider(
            min: 10,
            max: 60,
            divisions: 50,
            value: _budget,
            activeColor: AppColors.purple,
            label: 'RM ${_budget.round()}',
            onChanged: (v) => setState(() => _budget = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _loading ? null : _generate,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Generate Bespoke Design'),
            ),
          ),
        ],
      ),
    );
  }

  /// Small heading above each group of chips.
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      );

  /// A wrap of rounded chips. Selected chips are purple.
  Widget _chips({
    required List<String> options,
    required bool Function(String) isSelected,
    required ValueChanged<String> onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option),
            selected: isSelected(option),
            showCheckmark: false,
            selectedColor: AppColors.purple,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 13,
              color: isSelected(option) ? Colors.white : AppColors.ink,
            ),
            onSelected: (_) => onTap(option),
          ),
      ],
    );
  }

  /// White card with the AI result, or the fallback notice (FR-AI-03).
  Widget _buildResultCard(AiRecommendation result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.creamDeep),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.designTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.sage),
          ),
          const SizedBox(height: 8),
          Text(result.stylingNote, style: const TextStyle(fontSize: 13)),
          if (result.beadPalette.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final bead in result.beadPalette)
                  Chip(
                    label: Text(bead, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.sageLight,
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated price: RM ${result.estimatedPriceMYR.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const Divider(height: 28),
          Text(
            result.isFallback ? 'Handpicked pieces in stock' : 'Matching pieces in stock',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (result.matchedProducts.isEmpty)
            const Text(
              'No in-stock pieces match this budget yet. Try raising your budget.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            )
          else
            for (final product in result.matchedProducts) _productRow(product),
          const SizedBox(height: 12),
          const Text(
            'AI-generated styling suggestion — final availability subject to confirmation',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          _buildActions(result),
        ],
      ),
    );
  }

  /// One in-stock product line: name, category and price.
  Widget _productRow(BeadProduct product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.sage),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${product.name} (${product.category})', style: const TextStyle(fontSize: 13)),
          ),
          Text(
            'RM ${product.priceMYR.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Retry (fallback) or thumbs feedback (normal), then "Use in Reservation" below it.
  /// A Column (not one long Row) keeps everything inside the card on small phones.
  Widget _buildActions(AiRecommendation result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (result.isFallback)
              OutlinedButton(onPressed: _loading ? null : _generate, child: const Text('Retry AI'))
            else if (_feedback == 0) ...[
              IconButton(
                tooltip: 'Good suggestion',
                icon: const Icon(Icons.thumb_up_alt_outlined),
                onPressed: () => _vote(1),
              ),
              IconButton(
                tooltip: 'Not for me',
                icon: const Icon(Icons.thumb_down_alt_outlined),
                onPressed: () => _vote(-1),
              ),
            ] else
              const Expanded(
                child: Text(
                  'Thank you for your feedback!',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sage,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _useInReservation(result),
            child: const Text('Use in Reservation'),
          ),
        ),
      ],
    );
  }
}
