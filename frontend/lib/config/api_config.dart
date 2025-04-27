class ApiConfig {
  // Update this URL when your ngrok URL changes
  static const String baseUrl = 'https://35c4-144-122-129-53.ngrok-free.app';

  // API endpoints
  static String get searchEndpoint => '$baseUrl/search';
}
