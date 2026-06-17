class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String webBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String get effectiveBaseUrl {
    // Use webBaseUrl for web, baseUrl for mobile (10.0.2.2 maps to host localhost on Android)
    return const bool.fromEnvironment('dart.library.html')
        ? webBaseUrl
        : baseUrl;
  }
}
