import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/localization/context_l10n.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_shell.dart';
import 'features/catalog/data/repo/catalog_repository.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';
import 'l10n/generated/app_localizations.dart';

class MobileTaskApp extends StatelessWidget {
  const MobileTaskApp({
    required this.repository,
    required this.catalog,
    required this.preferences,
    super.key,
  });
  final CatalogRepository repository;
  final CatalogCubit catalog;
  final PreferencesCubit preferences;
  @override
  Widget build(BuildContext context) => RepositoryProvider.value(
    value: repository,
    child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: catalog),
        BlocProvider.value(value: preferences),
      ],
      child: BlocSelector<PreferencesCubit, PreferencesState, Locale>(
        selector: (state) => state.locale,
        builder: (context, locale) => MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.l10n.appTitle,
          theme: AppTheme.light(locale: locale),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppShell(),
        ),
      ),
    ),
  );
}
