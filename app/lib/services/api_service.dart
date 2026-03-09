import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_summary.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  Future<VideoSummary> fetchTranscript(String url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '자막 추출 실패');
    }

    final data = jsonDecode(response.body);
    return VideoSummary(
      videoId: data['video_id'],
      title: data['title'],
      thumbnailUrl: data['thumbnail_url'],
      transcript: data['transcript'],
      duration: data['duration'],
    );
  }

  Future<Map<String, dynamic>> summarize({
    required String videoId,
    required String title,
    required String transcript,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'title': title,
        'transcript': transcript,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '요약 실패');
    }

    return jsonDecode(response.body);
  }

  Future<String> chat({
    required String videoId,
    required String transcript,
    required String message,
    List<ChatMessage> history = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript': transcript,
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '채팅 실패');
    }

    final data = jsonDecode(response.body);
    return data['reply'];
  }
}
