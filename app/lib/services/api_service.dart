import 'package:dio/dio.dart';
import '../models/video_summary.dart';
import '../models/chat_message.dart';

class ApiService {
  late final Dio _dio;
  String _baseUrl;

  ApiService({String baseUrl = 'http://localhost:8000/api/v1'})
      : _baseUrl = baseUrl {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    _dio.options.baseUrl = newBaseUrl;
  }

  Future<Map<String, dynamic>> fetchTranscript(String url) async {
    final response = await _dio.post('/transcript', data: {'url': url});
    return response.data as Map<String, dynamic>;
  }

  Future<VideoSummary> fetchSummary(String url) async {
    final response = await _dio.post('/summarize', data: {'url': url});
    final data = response.data as Map<String, dynamic>;
    return VideoSummary.fromSummaryResponse(data);
  }

  Future<Map<String, dynamic>> sendChat(
    String url,
    String message,
    List<ChatMessage> history,
  ) async {
    final response = await _dio.post('/chat', data: {
      'url': url,
      'message': message,
      'history': history.map((m) => m.toJson()).toList(),
    });
    return response.data as Map<String, dynamic>;
  }
}
