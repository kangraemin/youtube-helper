import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_summary.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({required this.client, this.baseUrl = 'http://localhost:8000'});

  Future<VideoTranscript> fetchTranscript(String url) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      return VideoTranscript.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('자막을 가져오는데 실패했습니다: ${response.statusCode}');
    }
  }

  Future<VideoSummary> summarize(String videoId, String transcript) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'video_id': videoId, 'transcript': transcript}),
    );

    if (response.statusCode == 200) {
      return VideoSummary.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('요약에 실패했습니다: ${response.statusCode}');
    }
  }

  Future<String> chat(
    String videoId,
    String transcript,
    String message,
    List<ChatMessage> history,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript': transcript,
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String;
    } else {
      throw Exception('채팅 응답에 실패했습니다: ${response.statusCode}');
    }
  }
}
