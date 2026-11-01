class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'BYTEVAULT_API_URL',
    defaultValue: 'http://localhost:8080',
  );
}
