import '../../features/settings/data/preferences_store.dart';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/catalog/data/api/catalog_api_service.dart';
import '../../features/catalog/data/repo/catalog_repository.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../network/dio_factory.dart';

// The service locator is confined to the composition root. Features use constructors.
GetIt configureDependencies() {
  final services = GetIt.asNewInstance();
  services.registerLazySingleton<Dio>(
    DioFactory.create,
    dispose: (dio) => dio.close(),
  );
  services.registerLazySingleton(() => CatalogApiService(services<Dio>()));
  services.registerLazySingleton<CatalogRepository>(
    () => RemoteCatalogRepository(services<CatalogApiService>()),
  );
  services.registerLazySingleton<PreferencesStore>(
    () => DevicePreferencesStore(SharedPreferencesAsync()),
  );
  services.registerFactory(() => CatalogCubit(services<CatalogRepository>()));
  return services;
}
