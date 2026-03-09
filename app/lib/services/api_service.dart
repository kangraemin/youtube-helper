import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_summary.dart';

class ApiService {
  String _baseUrl;

  ApiService({String baseUrl = 'http://localhost:8000'}) : _baseUrl = baseUrl;

  String get baseUrl => _baseUrl;

  set baseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<Map<String, dynamic>> fetchTranscript(String url) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch transcript: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> summarize(
      String videoId, String transcript) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'video_id': videoId, 'transcript': transcript}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to summarize: ${response.statusCode}');
    }
  }

  Future<String> chat(String videoId, String transcript, String message,
      List<Map<String, String>> history) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript': transcript,
        'message': message,
        'history': history,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String;
    } else {
      throw Exception('Failed to chat: ${response.statusCode}');
    }
  }

  Future<VideoSummary> processVideo(String url) async {
    final transcriptData = await fetchTranscript(url);

    final videoId = transcriptData['video_id'] as String;
    final title = transcriptData['title'] as String? ?? '';
    final thumbnailUrl = transcriptData['thumbnail_url'] as String? ?? '';
    final transcript = transcriptData['transcript'] as String;
    final language = transcriptData['language'] as String? ?? 'ko';

    final summaryData = await summarize(videoId, transcript);

    return VideoSummary(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      transcript: transcript,
      summary: summaryData['summary'] as String? ?? '',
      keyPoints: (summaryData['key_points'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sections: (summaryData['sections'] as List<dynamic>?)
              ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      language: language,
    );
  }
}
