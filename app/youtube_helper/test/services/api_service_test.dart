import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:youtube_helper/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('fetchTranscript returns VideoTranscript on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/transcript');
        return http.Response(
          jsonEncode({
            'video_id': 'test123',
            'title': 'Test Video',
            'thumbnail_url': 'https://img.youtube.com/vi/test123/hqdefault.jpg',
            'duration': '5:30',
            'transcript': 'Hello world',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      final result = await api.fetchTranscript('https://youtube.com/watch?v=test123');

      expect(result.videoId, 'test123');
      expect(result.title, 'Test Video');
      expect(result.thumbnailUrl, contains('test123'));
      expect(result.transcript, 'Hello world');
    });

    test('fetchTranscript throws on error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"detail": "Invalid URL"}', 400);
      });

      final api = ApiService(client: mockClient);
      expect(
        () => api.fetchTranscript('bad-url'),
        throwsException,
      );
    });

    test('summarize returns VideoSummary on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/summarize');
        return http.Response(
          jsonEncode({
            'video_id': 'test123',
            'summary': 'This is a summary',
            'key_points': ['Point 1', 'Point 2'],
            'action_points': ['Action 1'],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      final result = await api.summarize('test123', 'transcript text');

      expect(result.videoId, 'test123');
      expect(result.summary, 'This is a summary');
      expect(result.keyPoints.length, 2);
      expect(result.actionPoints.length, 1);
    });

    test('chat returns reply on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/chat');
        return http.Response(
          jsonEncode({
            'video_id': 'test123',
            'reply': 'AI response here',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      final result = await api.chat('test123', 'transcript', 'question', []);

      expect(result, 'AI response here');
    });
  });
}
