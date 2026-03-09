import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youtube_helper/core/theme.dart';
import 'package:youtube_helper/data/api/api_client.dart';
import 'package:youtube_helper/data/models/video_summary.dart';
import 'package:youtube_helper/providers/summary_provider.dart';
import 'package:youtube_helper/providers/chat_provider.dart';
import 'package:youtube_helper/ui/detail/detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Fake SummaryProvider that doesn't depend on DB.
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
  Future<void> summarizeVideo(String url) async {}

  void setCurrentSummary(VideoSummary summary) {
    _currentSummary = summary;
    _state = SummaryState.success;
    notifyListeners();
  }

  @override
  void reset() {}
}

void main() {
  late FakeSummaryProvider summaryProvider;
  late ChatProvider chatProvider;

  final testSummary = VideoSummary(
    videoId: 'test123',
    title: 'Test Video',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    durationSeconds: 600,
    summary: 'This is the video summary',
    keyPoints: ['Key point 1', 'Key point 2'],
    sections: [
      SummarySection(title: 'Introduction', content: 'Intro content'),
      SummarySection(title: 'Main Body', content: 'Main content'),
    ],
    transcriptText: 'Full transcript text here',
  );

  Widget createTestWidget() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<SummaryProvider>.value(value: summaryProvider),
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
        ],
        child: const DetailScreen(videoId: 'test123'),
      ),
    );
  }

  setUp(() {
    summaryProvider = FakeSummaryProvider();
    final mockClient = MockClient((r) async =>
        http.Response('{"reply": "test"}', 200));
    chatProvider = ChatProvider(
      apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8000'),
    );
  });

  group('DetailScreen', () {
    testWidgets('shows "not found" when no summary', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('요약 데이터를 찾을 수 없습니다'), findsOneWidget);
    });

    testWidgets('shows tabs with summary data', (tester) async {
      summaryProvider.setCurrentSummary(testSummary);
      await tester.pumpWidget(createTestWidget());

      expect(find.text('요약'), findsOneWidget);
      expect(find.text('스크립트'), findsOneWidget);
      expect(find.text('전문'), findsOneWidget);
    });

    testWidgets('summary tab shows summary content', (tester) async {
      summaryProvider.setCurrentSummary(testSummary);
      await tester.pumpWidget(createTestWidget());

      expect(find.text('동영상 요약'), findsOneWidget);
      expect(find.text('This is the video summary'), findsOneWidget);
      expect(find.text('핵심 요점'), findsOneWidget);
      expect(find.text('Key point 1'), findsOneWidget);
    });

    testWidgets('script tab shows transcript', (tester) async {
      summaryProvider.setCurrentSummary(testSummary);
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('스크립트'));
      await tester.pump();
      await tester.pump();

      expect(find.text('자막 전문'), findsOneWidget);
      expect(find.text('Full transcript text here'), findsOneWidget);
    });

    testWidgets('has floating action button for chat', (tester) async {
      summaryProvider.setCurrentSummary(testSummary);
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
    });

    testWidgets('section titles shown in summary tab', (tester) async {
      summaryProvider.setCurrentSummary(testSummary);
      await tester.pumpWidget(createTestWidget());

      expect(find.text('항목 요약'), findsOneWidget);
      expect(find.text('Introduction'), findsOneWidget);
    });
  });
}
