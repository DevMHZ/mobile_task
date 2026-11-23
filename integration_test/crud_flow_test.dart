import 'package:mobile_task/main.dart' as app;
import 'package:mobile_task/my_app.dart';
import 'package:mobile_task/features/catalog/presentation/ui/product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('live edit, delete and create remain session scoped', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();
    final application = tester.widget<MobileTaskApp>(
      find.byType(MobileTaskApp),
    );
    await application.preferences.selectLocale('en');
    await tester.pumpAndSettle();
    final original = application.catalog.state.visible.first;
    await reveal(tester, find.text(original.title).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(original.title).first);
    await waitFor(tester, find.text('About this item'));
    await reveal(tester, find.text('Edit item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit item'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormScreen), findsOneWidget);
    const editedTitle = 'Assessment session edit';
    await tester.enterText(
      find.byKey(const ValueKey('item_title')),
      editedTitle,
    );
    await reveal(tester, find.byKey(const ValueKey('submit_item')));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('edit-en');
    await tester.tap(find.byKey(const ValueKey('submit_item')));
    await waitFor(tester, find.text(editedTitle));
    expect(
      application.catalog.state.products
          .firstWhere((p) => p.id == original.id)
          .title,
      editedTitle,
    );
    await application.catalog.load(refresh: true);
    expect(
      application.catalog.state.products
          .firstWhere((p) => p.id == original.id)
          .title,
      editedTitle,
    );
    while (find.byType(SnackBar).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await reveal(tester, find.text('Delete item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await waitFor(tester, find.text('Discover'));
    expect(
      application.catalog.state.products.any((p) => p.id == original.id),
      isFalse,
    );
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_item')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('item_title')),
      'Assessment session creation',
    );
    await tester.enterText(
      find.byKey(const ValueKey('item_description')),
      'Created through the assessment interface.',
    );
    await reveal(tester, find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Furniture').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('item_price')), '25.50');
    await reveal(tester, find.byKey(const ValueKey('item_image')));
    await tester.enterText(
      find.byKey(const ValueKey('item_image')),
      original.thumbnail,
    );
    await reveal(tester, find.byKey(const ValueKey('submit_item')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit_item')));
    await waitFor(tester, find.text('Manage collection'));
    final created = application.catalog.state.products
        .where((p) => p.id < 0)
        .single;
    expect(created.title, 'Assessment session creation');
    expect(created.rating, isNull);
    expect(tester.takeException(), isNull);
  });
}
