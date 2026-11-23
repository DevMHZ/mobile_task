import 'package:dio/dio.dart';

import '../config/app_config.dart';

abstract final class DioFactory {
  static Dio create() {
    final uri = Uri.parse(AppConfig.apiBaseUrl);
    if (!uri.hasAuthority || !['https', 'http'].contains(uri.scheme)) {
      throw ArgumentError('API_BASE_URL must be an absolute HTTP(S) URL.');
    }
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.connectTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
  }
}
