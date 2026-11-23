import 'package:mobile_task/core/network/app_failure.dart';
import 'package:mobile_task/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:mobile_task/features/catalog/presentation/ui/widgets/product_card.dart';
import 'package:mobile_task/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:mobile_task/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Cairo');
    for (final name in ['Regular', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Cairo-$name.ttf'));
    }
    await fonts.load();
  });

  for (final width in [320.0, 390.0, 800.0]) {
    for (final language in ['en', 'ar']) {
      testWidgets(
        'discovery and settings fit $width in $language at 1.3 text scale',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 1.3;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final repo = FixtureRepository();
          final catalog = CatalogCubit(repo);
          final preferences = PreferencesCubit(
            MemoryPreferences(),
            initialLocale: Locale(language),
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
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -300),
          );
          await tester.pumpAndSettle();
          expect(find.byType(ProductCard), findsWidgets);
          expect(tester.takeException(), isNull);
          final settings = language == 'ar' ? 'الملف الشخصي' : 'Profile';
          await tester.tap(find.text(settings));
          await tester.pumpAndSettle();
          expect(
            find.text(language == 'ar' ? 'اللغة' : 'Language'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'search, empty state, favorite, details and locale switch preserve navigation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FixtureRepository();
      final catalog = CatalogCubit(repo);
      final preferences = PreferencesCubit(MemoryPreferences());
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
      final first = catalog.state.visible.first;
      await tester.ensureVisible(
        find.byKey(ValueKey('favorite_${first.id}')).first,
      );
      await tester.tap(find.byKey(ValueKey('favorite_${first.id}')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text(first.title), findsOneWidget);
      await tester.tap(find.text(first.title));
      await tester.pumpAndSettle();
      expect(find.text('Overview'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(find.text('اللغة'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('اللغة'))),
        TextDirection.rtl,
      );
      await tester.tap(find.text('استكشف'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1500));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('catalog_search')),
        'zzz-no',
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 350));
      expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
      await tester.tap(find.text('إزالة التصفية'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('catalog_search')), findsOneWidget);
      expect(find.byType(ProductListCard), findsWidgets);
    },
  );

  testWidgets('loading and offline error expose a working retry', (
    tester,
  ) async {
    final repo = FixtureRepository()
      ..error = const AppFailure(FailureKind.offline);
    final catalog = CatalogCubit(repo);
    final preferences = PreferencesCubit(MemoryPreferences());
    addTearDown(catalog.close);
    addTearDown(preferences.close);
    await tester.pumpWidget(
      MobileTaskApp(
        repository: repo,
        catalog: catalog,
        preferences: preferences,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Loading the collection'), findsWidgets);
    await catalog.load();
    await tester.pumpAndSettle();
    expect(find.textContaining('You appear to be offline'), findsOneWidget);
    repo.error = null;
    await tester.ensureVisible(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byType(ProductCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'edit action stays visible with keyboard and closes after successful save',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final repo = FixtureRepository();
      final catalog = CatalogCubit(repo);
      final preferences = PreferencesCubit(MemoryPreferences());
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
      await tester.tap(find.text(catalog.state.visible.first.title).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit item'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('submit_item')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('item_title')),
        'A reviewed item',
      );
      await tester.tap(find.byKey(const ValueKey('submit_item')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('submit_item')), findsNothing);
      expect(find.text('A reviewed item'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('startup preference read failure can be retried from settings', (
    tester,
  ) async {
    final store = MemoryPreferences()..failRead = true;
    final preferences = PreferencesCubit(store);
    final repo = FixtureRepository();
    final catalog = CatalogCubit(repo);
    addTearDown(preferences.close);
    addTearDown(catalog.close);
    await preferences.restore();
    await catalog.load();
    await tester.pumpWidget(
      MobileTaskApp(
        repository: repo,
        catalog: catalog,
        preferences: preferences,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'We could not access your saved preferences. Please try again.',
      ),
      findsOneWidget,
    );
    store.failRead = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(preferences.state.failure, isNull);
    expect(
      find.text(
        'We could not access your saved preferences. Please try again.',
      ),
      findsNothing,
    );
  });
}
