import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/transcript.dart';
import '../models/chat_message.dart';

class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConstants.baseUrl;

  Future<Transcript> fetchTranscript(String url) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${AppConstants.transcriptEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      return Transcript.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw ApiException(
        'Failed to fetch transcript',
        response.statusCode,
      );
    }
  }

  Future<SummarizeResponse> summarize({
    required String videoId,
    required String title,
    required String transcriptText,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${AppConstants.summarizeEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'title': title,
        'transcript_text': transcriptText,
      }),
    );

    if (response.statusCode == 200) {
      return SummarizeResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw ApiException(
        'Failed to summarize',
        response.statusCode,
      );
    }
  }

  Future<String> chat({
    required String videoId,
    required String transcriptText,
    required List<ChatMessage> messages,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${AppConstants.chatEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript_text': transcriptText,
        'messages': messages.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String;
    } else {
      throw ApiException(
        'Failed to chat',
        response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class SummarizeResponse {
  final String videoId;
  final String summary;
  final List<String> keyPoints;
  final List<SummarySectionData> sections;

  SummarizeResponse({
    required this.videoId,
    required this.summary,
    required this.keyPoints,
    required this.sections,
  });

  factory SummarizeResponse.fromJson(Map<String, dynamic> json) {
    return SummarizeResponse(
      videoId: json['video_id'] as String,
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['key_points'] as List),
      sections: (json['sections'] as List)
          .map((s) => SummarySectionData.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SummarySectionData {
  final String title;
  final String content;

  SummarySectionData({required this.title, required this.content});

  factory SummarySectionData.fromJson(Map<String, dynamic> json) {
    return SummarySectionData(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
