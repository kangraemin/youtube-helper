import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:youtube_helper/data/api/api_client.dart';
import 'package:youtube_helper/data/models/chat_message.dart';

void main() {
  group('ApiClient', () {
    group('fetchTranscript', () {
      test('returns Transcript on 200 response', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/api/v1/transcript');
          expect(request.method, 'POST');
          final body = jsonDecode(request.body);
          expect(body['url'], 'https://youtube.com/watch?v=test');

          return http.Response(
            jsonEncode({
              'video_id': 'test',
              'title': 'Test Video',
              'thumbnail_url': 'https://img.youtube.com/vi/test/0.jpg',
              'duration_seconds': 600,
              'language': 'ko',
              'segments': [
                {'start': 0.0, 'duration': 5.0, 'text': 'Hello'},
                {'start': 5.0, 'duration': 3.0, 'text': 'World'},
              ],
              'transcript_text': 'Hello World',
            }),
            200,
          );
        });

        final client = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );

        final result = await client.fetchTranscript(
          'https://youtube.com/watch?v=test',
        );

        expect(result.videoId, 'test');
        expect(result.title, 'Test Video');
        expect(result.segments.length, 2);
        expect(result.transcriptText, 'Hello World');
        expect(result.language, 'ko');
      });

      test('throws ApiException on non-200 response', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not found', 404);
        });

        final client = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );

        expect(
          () => client.fetchTranscript('https://youtube.com/watch?v=bad'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('summarize', () {
      test('returns SummarizeResponse on 200', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/api/v1/summarize');
          final body = jsonDecode(request.body);
          expect(body['video_id'], 'test');

          return http.Response(
            jsonEncode({
              'video_id': 'test',
              'summary': 'This is a summary',
              'key_points': ['Point 1', 'Point 2'],
              'sections': [
                {'title': 'Section 1', 'content': 'Content 1'},
              ],
            }),
            200,
          );
        });

        final client = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );

        final result = await client.summarize(
          videoId: 'test',
          title: 'Test',
          transcriptText: 'transcript',
        );

        expect(result.videoId, 'test');
        expect(result.summary, 'This is a summary');
        expect(result.keyPoints.length, 2);
        expect(result.sections.length, 1);
      });

      test('throws ApiException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Server error', 500);
        });

        final client = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );

        expect(
          () => client.summarize(
            videoId: 'test',
            title: 'Test',
            transcriptText: 'text',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('chat', () {
      test('returns reply on 200', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/api/v1/chat');
          final body = jsonDecode(request.body);
          expect(body['video_id'], 'test');
          expect(body['messages'].length, 1);

          return http.Response(
            jsonEncode({'reply': 'AI response here'}),
            200,
          );
        });

        final client = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );

        final result = await client.chat(
          videoId: 'test',
          transcriptText: 'transcript',
          messages: [
            ChatMessage(role: 'user', content: 'Hello'),
          ],
        );

        expect(result, 'AI response here');
      });

      test('throws ApiException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Error', 503);
        });

        final client = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );

        expect(
          () => client.chat(
            videoId: 'test',
            transcriptText: 'text',
            messages: [],
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });

  group('ApiException', () {
    test('toString returns formatted message', () {
      final ex = ApiException('test error', 404);
      expect(ex.toString(), 'ApiException(404): test error');
    });
  });
}
