import 'package:beadaries_prototype/providers/admin_product_provider.dart';
import 'package:beadaries_prototype/screens/customer/catalogue_screen.dart';
import 'package:beadaries_prototype/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('catalogue displays and filters shared inventory products', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminProductProvider(
          repository: MockProductRepository(simulatedDelay: Duration.zero),
        ),
        child: const MaterialApp(home: CatalogueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('8 products'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sage Garden');
    await tester.pump();

    expect(find.text('1 products'), findsOneWidget);
    expect(find.text('Sage Garden Bead Bracelet'), findsOneWidget);
  });
}
