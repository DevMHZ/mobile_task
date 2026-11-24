import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_task/core/config/app_config.dart';
import 'package:mobile_task/core/theme/app_theme.dart';
import 'package:mobile_task/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:mobile_task/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:mobile_task/my_app.dart';

import 'support.dart';

void main() {
  setUpAll(loadAppFonts);
  testWidgets(
    'Arabic editor preserves content direction and separates the in-field counter',
    (tester) async {
      final repo = FixtureRepository();
      final catalog = CatalogCubit(repo);
      final preferences = PreferencesCubit(
        MemoryPreferences(),
        initialLocale: const Locale('ar'),
      );
      addTearDown(catalog.close);
      addTearDown(preferences.close);
      await catalog.load();
      await tester.pumpWidget(
        MobileTaskApp(
          repository: repo,
          catalog: catalog,
          preferences: preferences,
        ),
      );
      await tester.pumpAndSettle();
      final product = catalog.state.visible.first;
      await tester.tap(find.text(product.title).first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(
          '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0639\u0646\u0635\u0631',
        ),
      );
      await tester.pumpAndSettle();
      final title = find.byKey(const ValueKey('item_title'));
      final editable = find.descendant(
        of: title,
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(editable).textDirection,
        TextDirection.ltr,
      );
      final counter = find.descendant(
        of: title,
        matching: find.text(
          '${product.title.length}/${AppConfig.maxTitleLength}',
        ),
      );
      expect(
        tester.getRect(editable).left - tester.getRect(counter).right,
        greaterThanOrEqualTo(AppSpace.md),
      );
      await tester.enterText(
        title,
        '\u0639\u0646\u0648\u0627\u0646 \u0639\u0631\u0628\u064a',
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(editable).textDirection,
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
