import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  Future<Map<String, dynamic>> getTranscript(String youtubeUrl) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': youtubeUrl}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('자막 추출 실패: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> summarize(String transcript) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transcript': transcript}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('요약 실패: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> chat({
    required String transcript,
    required String question,
    List<Map<String, String>>? messages,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'transcript': transcript,
        'question': question,
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('채팅 실패: ${response.statusCode}');
    }
  }
}
