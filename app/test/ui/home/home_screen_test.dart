import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:youtube_helper/core/theme.dart';
import 'package:youtube_helper/data/api/api_client.dart';
import 'package:youtube_helper/data/models/video_summary.dart';
import 'package:youtube_helper/providers/summary_provider.dart';
import 'package:youtube_helper/ui/home/home_screen.dart';

/// A simple fake SummaryProvider for widget tests that doesn't need a database.
class FakeSummaryProvider extends ChangeNotifier implements SummaryProvider {
  SummaryState _state = SummaryState.idle;
  VideoSummary? _currentSummary;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  SummaryState get state => _state;
  @override
  VideoSummary? get currentSummary => _currentSummary;
  @override
  String? get errorMessage => _errorMessage;
  @override
  double get progress => _progress;

  @override
  Future<void> summarizeVideo(String url) async {
    _state = SummaryState.loading;
    _progress = 0.3;
    notifyListeners();
  }

  void setSuccess(VideoSummary summary) {
    _currentSummary = summary;
    _state = SummaryState.success;
    _progress = 1.0;
    notifyListeners();
  }

  void setError(String message) {
    _state = SummaryState.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void reset() {
    _state = SummaryState.idle;
    _currentSummary = null;
    _errorMessage = null;
    _progress = 0.0;
    notifyListeners();
  }
}

void main() {
  Widget createTestWidget(FakeSummaryProvider provider) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ChangeNotifierProvider<SummaryProvider>.value(
        value: provider,
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('displays app title and input field', (tester) async {
      final provider = FakeSummaryProvider();
      await tester.pumpWidget(createTestWidget(provider));

      expect(find.text('YouTube Helper'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('\u2728 요약하기'), findsOneWidget);
    });

    testWidgets('shows summary button', (tester) async {
      final provider = FakeSummaryProvider();
      await tester.pumpWidget(createTestWidget(provider));

      final button = find.widgetWithText(ElevatedButton, '\u2728 요약하기');
      expect(button, findsOneWidget);
    });

    testWidgets('does not trigger summarize with empty URL', (tester) async {
      final provider = FakeSummaryProvider();
      await tester.pumpWidget(createTestWidget(provider));

      await tester.tap(find.widgetWithText(ElevatedButton, '\u2728 요약하기'));
      await tester.pump();

      expect(provider.state, SummaryState.idle);
    });

    testWidgets('shows progress indicator when loading', (tester) async {
      final provider = FakeSummaryProvider();
      await tester.pumpWidget(createTestWidget(provider));

      await tester.enterText(find.byType(TextField), 'https://youtube.com/watch?v=test');
      await tester.tap(find.widgetWithText(ElevatedButton, '\u2728 요약하기'));
      await tester.pump();

      expect(find.textContaining('AI 요약 중'), findsOneWidget);
    });

    testWidgets('shows error card on error state', (tester) async {
      final provider = FakeSummaryProvider();
      await tester.pumpWidget(createTestWidget(provider));

      provider.setError('테스트 오류');
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('테스트 오류'), findsOneWidget);
    });

    testWidgets('shows video card on success', (tester) async {
      final provider = FakeSummaryProvider();
      provider.setSuccess(VideoSummary(
        videoId: 'test123',
        title: 'Test Video Title',
        thumbnailUrl: 'https://img.youtube.com/vi/test123/0.jpg',
        durationSeconds: 300,
        summary: 'A great summary of the video',
        keyPoints: ['Point 1'],
        sections: [],
        transcriptText: 'Transcript text',
      ));

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pump();

      expect(find.text('Test Video Title'), findsOneWidget);
      expect(find.text('전문 보기'), findsOneWidget);
    });

    testWidgets('has play circle icon in app bar', (tester) async {
      final provider = FakeSummaryProvider();
      await tester.pumpWidget(createTestWidget(provider));

      expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
    });

    testWidgets('has clipboard paste button in URL field', (tester) async {
      final provider = FakeSummaryProvider();
      await tester.pumpWidget(createTestWidget(provider));

      expect(find.byIcon(Icons.content_paste), findsOneWidget);
    });
  });
}
