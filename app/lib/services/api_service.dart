import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  Future<Map<String, dynamic>> getTranscript(String url) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      throw Exception('자막을 가져올 수 없습니다: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> summarize({
    required String url,
    required String transcript,
    String title = '',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'url': url,
        'transcript': transcript,
        'title': title,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('요약에 실패했습니다: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<String> chat({
    required String transcript,
    required String question,
    List<Map<String, String>>? history,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'transcript': transcript,
        'question': question,
        'history': history ?? [],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('채팅에 실패했습니다: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['answer'];
  }
}
