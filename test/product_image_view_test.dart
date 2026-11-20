import 'package:beadaries_prototype/widgets/product_image_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders picked image data through a memory image provider', (
    tester,
  ) async {
    const source =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jR4kAAAAASUVORK5CYII=';

    await tester.pumpWidget(
      const MaterialApp(
        home: ProductImageView(
          source: source,
          placeholder: Icon(Icons.image_not_supported),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
  });
}
