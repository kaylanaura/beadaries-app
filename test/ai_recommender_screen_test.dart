// File: test/ai_recommender_screen_test.dart
// Author: Kayla Binti Mohamad (102641)
// Requirement: FR-AI-01, FR-AI-03, FR-AI-04 | Branch: feat/fr-ai01-recommender
// Description: Widget tests for AiRecommenderScreen (validation, result card, fallback, feedback).

import 'package:beadaries_prototype/screens/customer/ai_recommender_screen.dart';
import 'package:beadaries_prototype/services/ai_recommender_service.dart';
import 'package:beadaries_prototype/models/ai_recommendation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the screen on a tall fake phone so nothing is hidden below the fold.
Future<void> _openScreen(
  WidgetTester tester,
  MockAiRecommenderService service,
) async {
  await tester.binding.setSurfaceSize(const Size(420, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(home: AiRecommenderScreen(service: service)),
  );
}

void main() {
  const disclaimer =
      'AI-generated styling suggestion — final availability subject to confirmation';

  testWidgets('FR-AI-01: blocks generate when no colour is selected', (
    tester,
  ) async {
    await _openScreen(tester, MockAiRecommenderService(delay: Duration.zero));

    await tester.tap(find.text('Cream & Sage')); // deselect the default colour
    await tester.pump();
    await tester.tap(find.text('Generate Bespoke Design'));
    await tester.pump();

    expect(
      find.text('Please pick at least one colour aesthetic.'),
      findsOneWidget,
    );
    expect(find.text(disclaimer), findsNothing);
  });

  testWidgets('FR-AI-01: shows a result card with the AI disclaimer', (
    tester,
  ) async {
    await _openScreen(tester, MockAiRecommenderService(delay: Duration.zero));

    await tester.tap(find.text('Generate Bespoke Design'));
    await tester.pumpAndSettle();

    expect(find.text(disclaimer), findsOneWidget);
    expect(find.text('Use in Reservation'), findsOneWidget);
  });

  testWidgets('FR-AI-03: shows the fallback notice and Retry AI on outage', (
    tester,
  ) async {
    await _openScreen(
      tester,
      MockAiRecommenderService(delay: Duration.zero, simulateOutage: true),
    );

    await tester.tap(find.text('Generate Bespoke Design'));
    await tester.pumpAndSettle();

    expect(find.textContaining('short breather'), findsOneWidget);
    expect(find.text('Retry AI'), findsOneWidget);
  });

  testWidgets('FR-AI-04: thumbs up shows the thank-you message once', (
    tester,
  ) async {
    await _openScreen(tester, MockAiRecommenderService(delay: Duration.zero));

    await tester.tap(find.text('Generate Bespoke Design'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined));
    await tester.pump();

    expect(find.text('Thank you for your feedback!'), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_alt_outlined), findsNothing);
  });

  testWidgets('FR-AI-04: Use in Reservation passes the design to the shell', (
    tester,
  ) async {
    AiRecommendation? handedOff;
    await tester.binding.setSurfaceSize(const Size(420, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: AiRecommenderScreen(
          service: MockAiRecommenderService(delay: Duration.zero),
          onUseInReservation: (recommendation) {
            handedOff = recommendation;
          },
        ),
      ),
    );

    await tester.tap(find.text('Generate Bespoke Design'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use in Reservation'));
    await tester.pump();

    expect(handedOff, isNotNull);
    expect(handedOff!.designSummary, isNotEmpty);
  });
}
