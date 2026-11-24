import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_task/core/navigation/app_shell.dart';
import 'package:mobile_task/features/catalog/presentation/ui/filter_sheet.dart';
import 'package:mobile_task/features/catalog/presentation/ui/manage_collection_screen.dart';
import 'package:mobile_task/features/catalog/presentation/ui/product_details_screen.dart';
import 'package:mobile_task/features/catalog/presentation/ui/product_form_screen.dart';
import 'package:mobile_task/features/catalog/presentation/ui/product_gallery_screen.dart';
import 'package:mobile_task/features/catalog/presentation/ui/widgets/product_card.dart';
import 'package:mobile_task/features/settings/data/preferences_store.dart';
import 'package:mobile_task/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:mobile_task/l10n/generated/app_localizations.dart';
import 'package:mobile_task/main.dart' as app;
import 'package:mobile_task/my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    ..framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets(
    'submission journey covers both languages with live API and persisted preferences',
    (tester) async {
      await app.main();
      await settle(tester);
      final application = tester.widget<MobileTaskApp>(
        find.byType(MobileTaskApp),
      );
      expect(application.catalog.state.products, isNotEmpty);
      Future<void> tab(int index) async {
        await tester.tap(find.byKey(ValueKey('nav_$index')));
        await settle(tester);
      }

      Future<void> capture(String name) async {
        await settle(tester);
        debugPrint('Capturing $name');
        await binding.takeScreenshot(name).timeout(const Duration(seconds: 30));
      }

      Future<void> back() async {
        await tester.binding.handlePopRoute();
        await settle(tester);
      }

      for (final language in ['en', 'ar']) {
        await tab(2);
        await reveal(
          tester,
          find
              .text(language == 'ar' ? 'العربية' : 'English')
              .hitTestable()
              .last,
        );
        await tester.tap(
          find
              .text(language == 'ar' ? 'العربية' : 'English')
              .hitTestable()
              .last,
        );
        await settle(tester);
        expect(application.preferences.state.locale.languageCode, language);
        final l = AppLocalizations.of(tester.element(find.byType(AppShell)));
        await capture('settings-$language');
        await tab(0);
        await waitFor(tester, find.byType(FeaturedProductCard).first);
        final first = application.catalog.state.visible.first;
        await waitFor(
          tester,
          find.descendant(
            of: find.byType(FeaturedProductCard).first,
            matching: find.byWidgetPredicate(
              (w) => w is RawImage && w.image != null,
            ),
          ),
        );
        await capture('home-$language');
        final favorite = find.byKey(ValueKey('favorite_${first.id}')).first;
        if (!application.preferences.state.favorites.contains(first.id)) {
          await tester.tap(favorite);
          await settle(tester);
        }
        await tester.tap(find.text(first.title).first);
        await waitFor(tester, find.byType(ProductDetailsScreen));
        await waitFor(tester, find.text(l.aboutItem));
        await capture('details-$language');
        await tester.tap(find.byKey(const ValueKey('item_actions')));
        await settle(tester);
        await tester.tap(find.byKey(const ValueKey('delete_item_action')));
        await settle(tester);
        await capture('delete-confirm-$language');
        await tester.tap(find.byKey(const ValueKey('cancel_delete')));
        await settle(tester);
        await reveal(tester, find.byKey(const ValueKey('gallery_thumbnail_0')));
        await tester.tap(find.byKey(const ValueKey('gallery_thumbnail_0')));
        await waitFor(tester, find.byType(ProductGalleryScreen));
        await waitFor(
          tester,
          find.descendant(
            of: find.byType(ProductGalleryScreen),
            matching: find.byWidgetPredicate(
              (w) => w is RawImage && w.image != null,
            ),
          ),
        );
        await capture('gallery-$language');
        if (first.images.length > 1) {
          final gallery = find.byType(ProductGalleryScreen);
          final bounds = tester.getRect(gallery);
          final start = Offset(
            bounds.left + bounds.width * (language == 'ar' ? .2 : .8),
            bounds.center.dy,
          );
          final end = Offset(
            bounds.left + bounds.width * (language == 'ar' ? .8 : .2),
            bounds.center.dy,
          );
          await tester.timedDragFrom(
            start,
            end - start,
            const Duration(milliseconds: 300),
          );
          await settle(tester);
          expect(find.text('2 / ${first.images.length}'), findsOneWidget);
        }
        await back();
        await reveal(tester, find.text(l.editItem).hitTestable().last);
        await tester.tap(find.text(l.editItem).hitTestable().last);
        await waitFor(tester, find.byType(ProductFormScreen));
        await capture('edit-$language');
        await back();
        await back();
        await tab(1);
        await capture('explore-$language');
        await tester.tap(find.byKey(const ValueKey('open_filters')));
        await waitFor(tester, find.byType(FilterSheet));
        await capture('filter-$language');
        await tester.tap(
          find.descendant(
            of: find.byType(FilterSheet),
            matching: find.byIcon(Icons.arrow_back_rounded),
          ),
        );
        await settle(tester);
        expect(find.byType(FilterSheet), findsNothing);
        await tester.tap(find.byKey(const ValueKey('catalog_search')));
        await settle(tester);
        await tester.enterText(
          find.byKey(const ValueKey('catalog_search')),
          'zzzz-no-product',
        );
        await tester.pump(const Duration(milliseconds: 350));
        await settle(tester);
        await waitFor(tester, find.text(l.noResults));
        FocusManager.instance.primaryFocus?.unfocus();
        await capture('empty-$language');
        await tester.tap(find.byTooltip(l.clearSearch));
        await settle(tester);
        await tab(2);
        await reveal(tester, find.text(l.saved).hitTestable());
        await tester.tap(find.text(l.saved).hitTestable());
        await settle(tester);
        expect(find.text(first.title), findsWidgets);
        await capture('saved-$language');
        await back();
        await reveal(tester, find.text(l.manage).hitTestable());
        await tester.tap(find.text(l.manage).hitTestable());
        await waitFor(tester, find.byType(ManageCollectionScreen));
        await capture('manage-$language');
        await tester.tap(find.byKey(const ValueKey('add_item')));
        await waitFor(tester, find.byType(ProductFormScreen));
        await capture('add-$language');
        await back();
        await back();
        expect(tester.takeException(), isNull);
      }
      final restored = PreferencesCubit(
        DevicePreferencesStore(SharedPreferencesAsync()),
      );
      await restored.restore();
      expect(restored.state.locale.languageCode, 'ar');
      expect(restored.state.favorites, isNotEmpty);
      await restored.close();
    },
  );
}
