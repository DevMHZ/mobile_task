import 'test_helpers.dart';

import 'package:mobile_task/features/settings/data/preferences_store.dart';
import 'package:mobile_task/main.dart' as app;
import 'package:mobile_task/features/catalog/presentation/ui/widgets/product_card.dart';
import 'package:mobile_task/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:mobile_task/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'live API, details, favorites, search, RTL and device persistence',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final application = tester.widget<MobileTaskApp>(
        find.byType(MobileTaskApp),
      );
      await application.preferences.selectLocale('en');
      await tester.pumpAndSettle();
      expect(
        application.catalog.state.products,
        isNotEmpty,
        reason: 'This integration requires live DummyJSON access.',
      );
      expect(find.byType(ProductCard), findsWidgets);
      final first = application.catalog.state.visible.first;
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('home-en');
      await tester.ensureVisible(find.byKey(ValueKey('favorite_${first.id}')));
      if (!application.preferences.state.favorites.contains(first.id)) {
        await tester.tap(find.byKey(ValueKey('favorite_${first.id}')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(first.title).first);
      await tester.pumpAndSettle();
      await waitFor(tester, find.text('About this item'));
      expect(find.text('About this item'), findsOneWidget);
      await waitFor(
        tester,
        find.byWidgetPredicate((w) => w is RawImage && w.image != null),
      );
      await binding.takeScreenshot('details-en');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text(first.title), findsOneWidget);
      await binding.takeScreenshot('saved-en');
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('settings-en');
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(find.text('اللغة'), findsOneWidget);
      await binding.takeScreenshot('settings-ar');
      expect(
        Directionality.of(tester.element(find.text('اللغة'))),
        TextDirection.rtl,
      );
      final restored = PreferencesCubit(
        DevicePreferencesStore(SharedPreferencesAsync()),
      );
      await restored.restore();
      expect(restored.state.locale.languageCode, 'ar');
      expect(restored.state.favorites.contains(first.id), isTrue);
      await restored.close();
      await tester.tap(find.text('اكتشف'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1500));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('catalog_search')));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1500));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('home-ar');
      await tester.enterText(
        find.byKey(const ValueKey('catalog_search')),
        'zzzz-no-product',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('empty-ar');
      expect(tester.takeException(), isNull);
    },
  );
}
