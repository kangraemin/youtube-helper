import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class TranscriptResponse {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String transcript;
  final String language;

  TranscriptResponse({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.transcript,
    required this.language,
  });

  factory TranscriptResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptResponse(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      duration: json['duration'] as String? ?? '',
      transcript: json['transcript'] as String,
      language: json['language'] as String? ?? 'ko',
    );
  }
}

class SummarizeResponse {
  final String summary;
  final List<String> keyPoints;
  final String transcriptPreview;

  SummarizeResponse({
    required this.summary,
    required this.keyPoints,
    required this.transcriptPreview,
  });

  factory SummarizeResponse.fromJson(Map<String, dynamic> json) {
    return SummarizeResponse(
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['key_points'] as List),
      transcriptPreview: json['transcript_preview'] as String? ?? '',
    );
  }
}

class ChatResponse {
  final String answer;

  ChatResponse({required this.answer});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'] as String,
    );
  }
}

class ApiService {
  final http.Client _client;
  String _baseUrl;

  ApiService({
    http.Client? client,
    String baseUrl = 'http://localhost:8000',
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  String get baseUrl => _baseUrl;

  set baseUrl(String url) {
    _baseUrl = url;
  }

  Future<TranscriptResponse> fetchTranscript(String url) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/transcript'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      return TranscriptResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        'Failed to fetch transcript',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<SummarizeResponse> summarize(
    String videoId,
    String transcript,
    String title,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript': transcript,
        'title': title,
      }),
    );

    if (response.statusCode == 200) {
      return SummarizeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        'Failed to summarize',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<ChatResponse> chat(
    String videoId,
    String transcript,
    String question,
    List<ChatMessage> history,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'transcript': transcript,
        'question': question,
        'history': history.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return ChatResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        'Failed to chat',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
