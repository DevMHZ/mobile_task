import 'package:mobile_task/main.dart' as app;
import 'package:mobile_task/my_app.dart';
import 'package:mobile_task/features/catalog/presentation/ui/product_form_screen.dart';
import 'package:mobile_task/features/catalog/presentation/ui/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('live edit, delete and create remain session scoped', (
    tester,
  ) async {
    await app.main();
    await settle(tester);
    final application = tester.widget<MobileTaskApp>(
      find.byType(MobileTaskApp),
    );
    await application.preferences.selectLocale('en');
    await settle(tester);
    final original = application.catalog.state.visible.first;
    await reveal(tester, find.text(original.title).first);
    await settle(tester);
    await tester.tap(find.text(original.title).first);
    await waitFor(tester, find.text('Overview'));
    await reveal(tester, find.text('Edit item'));
    await settle(tester);
    await tester.tap(find.text('Edit item'));
    await settle(tester);
    expect(find.byType(ProductFormScreen), findsOneWidget);
    const editedTitle = 'Assessment session edit';
    await tester.enterText(
      find.byKey(const ValueKey('item_title')),
      editedTitle,
    );
    await reveal(tester, find.byKey(const ValueKey('submit_item')));
    await settle(tester);
    await binding.takeScreenshot('crud-edit-en');
    await tester.tap(find.byKey(const ValueKey('submit_item')));
    await waitUntilGone(tester, find.byType(ProductFormScreen));
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
    await waitUntilGone(tester, find.byType(SnackBar));
    await tester.tap(find.byKey(const ValueKey('item_actions')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('delete_item_action')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('confirm_delete')));
    await waitUntilGone(tester, find.byType(ProductDetailsScreen));
    expect(
      application.catalog.state.products.any((p) => p.id == original.id),
      isFalse,
    );
    await tester.tap(find.byKey(const ValueKey('nav_2')));
    await settle(tester);
    await tester.tap(find.text('Manage collection'));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('add_item')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('item_title')),
      'Assessment session creation',
    );
    await tester.enterText(
      find.byKey(const ValueKey('item_description')),
      'Created through the assessment interface.',
    );
    await reveal(tester, find.byType(DropdownButtonFormField<String>));
    await settle(tester);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await settle(tester);
    await tester.tap(find.text('Furniture').last);
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('item_price')), '25.50');
    await reveal(tester, find.byKey(const ValueKey('item_image')));
    await tester.enterText(
      find.byKey(const ValueKey('item_image')),
      original.thumbnail,
    );
    await reveal(tester, find.byKey(const ValueKey('submit_item')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('submit_item')));
    await waitUntilGone(tester, find.byType(ProductFormScreen));
    await waitFor(tester, find.text('Manage collection'));
    final created = application.catalog.state.products
        .where((p) => p.id < 0)
        .single;
    expect(created.title, 'Assessment session creation');
    expect(created.rating, isNull);
    expect(tester.takeException(), isNull);
  });
}
