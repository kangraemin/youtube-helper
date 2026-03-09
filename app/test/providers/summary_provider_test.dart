import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:youtube_helper/data/api/api_client.dart';
import 'package:youtube_helper/data/local/database_helper.dart';
import 'package:youtube_helper/providers/summary_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for desktop testing
  sqfliteFfiInit();

  group('SummaryProvider', () {
    late SummaryProvider provider;
    late ApiClient apiClient;
    late DatabaseHelper dbHelper;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE summaries(
                video_id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                thumbnail_url TEXT NOT NULL,
                duration_seconds INTEGER NOT NULL,
                summary TEXT NOT NULL,
                key_points TEXT NOT NULL,
                transcript_text TEXT NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
          },
        ),
      );

      dbHelper = DatabaseHelper(databaseFactory: () async => db);
    });

    test('initial state is idle', () {
      final mockClient = MockClient((request) async {
        return http.Response('', 200);
      });
      apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8000');
      provider = SummaryProvider(apiClient: apiClient, dbHelper: dbHelper);

      expect(provider.state, SummaryState.idle);
      expect(provider.currentSummary, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.progress, 0.0);
    });

    test('summarizeVideo transitions through states on success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('transcript')) {
          return http.Response(
            jsonEncode({
              'video_id': 'test123',
              'title': 'Test Video',
              'thumbnail_url': 'https://img.youtube.com/vi/test123/0.jpg',
              'duration_seconds': 300,
              'language': 'ko',
              'segments': [
                {'start': 0.0, 'duration': 5.0, 'text': 'Hello'},
              ],
              'transcript_text': 'Hello transcript',
            }),
            200,
          );
        } else if (request.url.path.contains('summarize')) {
          return http.Response(
            jsonEncode({
              'video_id': 'test123',
              'summary': 'Video summary',
              'key_points': ['Point A'],
              'sections': [
                {'title': 'S1', 'content': 'C1'},
              ],
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8000');
      provider = SummaryProvider(apiClient: apiClient, dbHelper: dbHelper);

      final states = <SummaryState>[];
      provider.addListener(() {
        states.add(provider.state);
      });

      await provider.summarizeVideo('https://youtube.com/watch?v=test123');

      expect(provider.state, SummaryState.success);
      expect(provider.currentSummary, isNotNull);
      expect(provider.currentSummary!.videoId, 'test123');
      expect(provider.currentSummary!.title, 'Test Video');
      expect(provider.currentSummary!.summary, 'Video summary');
      expect(provider.progress, 1.0);

      // Verify it went through loading state
      expect(states.contains(SummaryState.loading), isTrue);
    });

    test('summarizeVideo sets error state on failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8000');
      provider = SummaryProvider(apiClient: apiClient, dbHelper: dbHelper);

      await provider.summarizeVideo('https://youtube.com/watch?v=bad');

      expect(provider.state, SummaryState.error);
      expect(provider.errorMessage, isNotNull);
    });

    test('reset clears all state', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('transcript')) {
          return http.Response(
            jsonEncode({
              'video_id': 'test',
              'title': 'Test',
              'thumbnail_url': 'url',
              'duration_seconds': 100,
              'language': 'ko',
              'segments': [],
              'transcript_text': 'text',
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'video_id': 'test',
            'summary': 'sum',
            'key_points': [],
            'sections': [],
          }),
          200,
        );
      });

      apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8000');
      provider = SummaryProvider(apiClient: apiClient, dbHelper: dbHelper);

      await provider.summarizeVideo('https://youtube.com/watch?v=test');
      expect(provider.state, SummaryState.success);

      provider.reset();
      expect(provider.state, SummaryState.idle);
      expect(provider.currentSummary, isNull);
      expect(provider.progress, 0.0);
    });
  });
}
