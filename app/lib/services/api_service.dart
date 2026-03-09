import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/video_summary.dart';
import '../models/chat_message.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  Future<VideoSummary> fetchTranscript(String url) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      throw ApiException('자막을 가져올 수 없습니다: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return VideoSummary.fromJson(json);
  }

  Future<VideoSummary> summarize(VideoSummary video) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': video.videoId,
        'title': video.title,
        'full_text': video.fullText,
        'language': video.language,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException('요약에 실패했습니다: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return video.copyWith(
      summary: json['summary'] as String?,
      keyPoints: (json['key_points'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      fullSummary: json['full_summary'] as String?,
    );
  }

  Future<String> chat({
    required String videoId,
    required String fullText,
    required List<ChatMessage> messages,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'full_text': fullText,
        'messages': messages.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException('채팅에 실패했습니다: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['reply'] as String;
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
