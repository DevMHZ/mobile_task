abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dummyjson.com',
  );
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 25);
  static const searchDebounce = Duration(milliseconds: 300);
  static const feedbackDuration = Duration(seconds: 3);
  static const errorFeedbackDuration = Duration(seconds: 5);
  static const motion = Duration(milliseconds: 200);
  static const pageSize = 20;
  static const maxTitleLength = 120;
  static const maxDescriptionLength = 2000;
}
