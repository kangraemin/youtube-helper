import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube_helper/features/summarize/domain/entities/chat_message.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchTranscript(String url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Transcript fetch failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<String> fetchSummary({
    required String videoId,
    required String title,
    required String fullText,
    String language = 'ko',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'title': title,
        'full_text': fullText,
        'language': language,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Summary fetch failed');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['summary']
        as String;
  }

  Future<String> sendChat({
    required String videoId,
    required String title,
    required String fullText,
    required List<ChatMessage> messages,
    String language = 'ko',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'title': title,
        'full_text': fullText,
        'messages': messages.map((m) => m.toJson()).toList(),
        'language': language,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Chat failed');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['reply']
        as String;
  }
}
