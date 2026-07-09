class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sectros.com',
  );

  static const String apiPrefix = '/central-api';
  static String get apiUrl => '$baseUrl$apiPrefix';
}
