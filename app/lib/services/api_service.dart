import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_summary.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://localhost:8000';
  final String baseUrl;

  ApiService({this.baseUrl = defaultBaseUrl});

  Future<VideoSummary> fetchTranscript(String url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      throw Exception('자막을 가져오는데 실패했습니다: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return VideoSummary(
      videoId: data['video_id'] as String,
      title: data['title'] as String,
      thumbnail: data['thumbnail'] as String,
      transcript: data['transcript'] as String,
      duration: data['duration'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> summarize(
    String videoId,
    String transcript,
    String title,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript': transcript,
        'title': title,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('요약에 실패했습니다: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<String> chat(
    String videoId,
    String transcript,
    String question,
    List<Map<String, String>> history,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript': transcript,
        'question': question,
        'history': history,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('채팅에 실패했습니다: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['answer'] as String;
  }
}
