class ApiConstants {
  ApiConstants._();

  static const String defaultBaseUrl = 'http://158.179.166.232:8000';
  static const String apiPrefix = '/api/v1';

  static String transcriptEndpoint(String baseUrl) =>
      '$baseUrl$apiPrefix/transcript';
  static String summarizeEndpoint(String baseUrl) =>
      '$baseUrl$apiPrefix/summarize';
  static String chatEndpoint(String baseUrl) => '$baseUrl$apiPrefix/chat';
  static String healthEndpoint(String baseUrl) => '$baseUrl$apiPrefix/health';

  static String thumbnailUrl(String videoId) =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}
