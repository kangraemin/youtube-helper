import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:youtube_helper/providers/summary_provider.dart';
import 'package:youtube_helper/services/api_service.dart';

void main() {
  group('SummaryNotifier', () {
    late ProviderContainer container;

    setUp(() {
      final mockClient = http_testing.MockClient((request) async {
        if (request.url.path == '/api/v1/transcript') {
          return http.Response(
            jsonEncode({
              'video_id': 'test123',
              'title': '테스트 영상',
              'thumbnail_url': 'https://img.youtube.com/vi/test123/hqdefault.jpg',
              'duration': '10:30',
              'transcript': '자막 내용입니다',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/api/v1/summarize') {
          return http.Response(
            jsonEncode({
              'video_id': 'test123',
              'summary': '영상 요약입니다',
              'key_points': ['핵심 1', '핵심 2'],
              'action_points': ['활용 1'],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(
            ApiService(client: mockClient),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태는 idle이다', () {
      final state = container.read(summaryProvider);
      expect(state.status, SummaryStatus.idle);
      expect(state.progress, 0);
    });

    test('summarize 성공 시 transcript와 summary를 갖는다', () async {
      await container.read(summaryProvider.notifier).summarize(
        'https://youtube.com/watch?v=test123',
      );

      final state = container.read(summaryProvider);
      expect(state.status, SummaryStatus.done);
      expect(state.transcript, isNotNull);
      expect(state.transcript!.videoId, 'test123');
      expect(state.summary, isNotNull);
      expect(state.summary!.summary, '영상 요약입니다');
      expect(state.progress, 1.0);
    });

    test('summarize 실패 시 error 상태가 된다', () async {
      final failClient = http_testing.MockClient((request) async {
        return http.Response('Error', 500);
      });

      final failContainer = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(
            ApiService(client: failClient),
          ),
        ],
      );

      await failContainer.read(summaryProvider.notifier).summarize(
        'https://youtube.com/watch?v=bad',
      );

      final state = failContainer.read(summaryProvider);
      expect(state.status, SummaryStatus.error);
      expect(state.errorMessage, isNotNull);

      failContainer.dispose();
    });

    test('reset 후 idle 상태로 돌아간다', () async {
      final notifier = container.read(summaryProvider.notifier);
      await notifier.summarize('https://youtube.com/watch?v=test123');
      notifier.reset();

      final state = container.read(summaryProvider);
      expect(state.status, SummaryStatus.idle);
      expect(state.transcript, isNull);
      expect(state.summary, isNull);
    });
  });
}
