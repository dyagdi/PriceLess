class ApiConfig {
  // Update this URL when your ngrok URL changes
  static const String baseUrl =
      'https://priceless-weaviate-production.up.railway.app';

  // API endpoints
  static String get searchEndpoint => '$baseUrl/search';
}
