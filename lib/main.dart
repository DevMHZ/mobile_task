import 'features/settings/data/preferences_store.dart';

import 'dart:ui';

import 'package:flutter/material.dart';

import 'core/di/di.dart';
import 'features/catalog/data/repo/catalog_repository.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = configureDependencies();
  final language = PlatformDispatcher.instance.locale.languageCode;
  final preferences = PreferencesCubit(
    services<PreferencesStore>(),
    initialLocale: Locale(language == 'ar' ? 'ar' : 'en'),
  );
  await preferences.restore();
  final catalog = services<CatalogCubit>();
  runApp(
    MobileTaskApp(
      repository: services<CatalogRepository>(),
      catalog: catalog,
      preferences: preferences,
    ),
  );
  await catalog.load();
}
