import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:youtube_helper/core/constants/api_constants.dart';

class TranscriptResponse {
  final String transcript;
  final String videoTitle;
  final String videoId;

  TranscriptResponse({
    required this.transcript,
    required this.videoTitle,
    required this.videoId,
  });

  factory TranscriptResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptResponse(
      transcript: json['transcript'] as String,
      videoTitle: json['video_title'] as String,
      videoId: json['video_id'] as String,
    );
  }
}

class SummarizeResponse {
  final String summary;

  SummarizeResponse({required this.summary});

  factory SummarizeResponse.fromJson(Map<String, dynamic> json) {
    return SummarizeResponse(
      summary: json['summary'] as String,
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

class SummaryApiService {
  final http.Client _client;
  final String baseUrl;

  SummaryApiService({
    http.Client? client,
    required this.baseUrl,
  }) : _client = client ?? http.Client();

  Future<TranscriptResponse> fetchTranscript(String url) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.transcriptEndpoint(baseUrl)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        '자막 추출에 실패했습니다 (${response.statusCode})',
        response.statusCode,
      );
    }

    return TranscriptResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<SummarizeResponse> summarize(String transcript) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.summarizeEndpoint(baseUrl)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transcript': transcript}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        '요약에 실패했습니다 (${response.statusCode})',
        response.statusCode,
      );
    }

    return SummarizeResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<ChatResponse> chat({
    required String question,
    required String transcript,
    required String summary,
    List<Map<String, String>>? history,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.chatEndpoint(baseUrl)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'transcript': transcript,
        'summary': summary,
        'history': ?history,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        '채팅 응답에 실패했습니다 (${response.statusCode})',
        response.statusCode,
      );
    }

    return ChatResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
