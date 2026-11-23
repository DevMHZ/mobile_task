import 'package:dio/dio.dart';

enum FailureKind {
  offline,
  timeout,
  server,
  invalidResponse,
  storage,
  cancelled,
}

final class AppFailure implements Exception {
  const AppFailure(this.kind, {this.statusCode});
  final FailureKind kind;
  final int? statusCode;

  static AppFailure from(Object error) {
    if (error is AppFailure) return error;
    if (error is DioException) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => const AppFailure(
          FailureKind.timeout,
        ),
        DioExceptionType.connectionError => const AppFailure(
          FailureKind.offline,
        ),
        DioExceptionType.cancel => const AppFailure(FailureKind.cancelled),
        DioExceptionType.badResponse => AppFailure(
          FailureKind.server,
          statusCode: error.response?.statusCode,
        ),
        _ => const AppFailure(FailureKind.invalidResponse),
      };
    }
    return const AppFailure(FailureKind.invalidResponse);
  }
}
