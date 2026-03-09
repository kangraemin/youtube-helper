import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youtube_helper/core/theme.dart';
import 'package:youtube_helper/data/local/database_helper.dart';
import 'package:youtube_helper/data/models/video_summary.dart';
import 'package:youtube_helper/providers/history_provider.dart';
import 'package:youtube_helper/ui/history/history_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late HistoryProvider provider;
  late DatabaseHelper dbHelper;

  Future<DatabaseHelper> createDbHelper() async {
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
    return DatabaseHelper(databaseFactory: () async => db);
  }

  Widget createTestWidget(HistoryProvider provider) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ChangeNotifierProvider.value(
        value: provider,
        child: const HistoryScreen(),
      ),
    );
  }

  group('HistoryScreen', () {
    testWidgets('shows title', (tester) async {
      dbHelper = await createDbHelper();
      provider = HistoryProvider(dbHelper: dbHelper);

      await tester.pumpWidget(createTestWidget(provider));
      // pump a few frames for the microtask to complete
      await tester.pump();
      await tester.pump();

      expect(find.text('히스토리'), findsOneWidget);
    });

    testWidgets('shows empty state when no history', (tester) async {
      dbHelper = await createDbHelper();
      provider = HistoryProvider(dbHelper: dbHelper);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pump();
      await tester.pump();

      expect(find.text('아직 요약한 영상이 없어요'), findsOneWidget);
    });

    testWidgets('shows history items when data exists', (tester) async {
      dbHelper = await createDbHelper();

      await dbHelper.insertSummary(VideoSummary(
        videoId: 'vid1',
        title: 'First Video',
        thumbnailUrl: 'https://example.com/1.jpg',
        durationSeconds: 300,
        summary: 'Summary of first video',
        keyPoints: ['Point 1'],
        sections: [],
        transcriptText: 'Transcript 1',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      ));

      provider = HistoryProvider(dbHelper: dbHelper);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pump();
      await tester.pump();

      expect(find.text('최근 요약 기록'), findsOneWidget);
      expect(find.text('First Video'), findsOneWidget);
    });

    testWidgets('delete button removes item', (tester) async {
      dbHelper = await createDbHelper();

      await dbHelper.insertSummary(VideoSummary(
        videoId: 'vid1',
        title: 'Video to Delete',
        thumbnailUrl: 'https://example.com/1.jpg',
        durationSeconds: 300,
        summary: 'Summary',
        keyPoints: [],
        sections: [],
        transcriptText: 'Transcript',
        createdAt: DateTime(2024, 1, 15),
      ));

      provider = HistoryProvider(dbHelper: dbHelper);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pump();
      await tester.pump();

      expect(find.text('Video to Delete'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();
      await tester.pump();

      expect(find.text('아직 요약한 영상이 없어요'), findsOneWidget);
    });
  });
}
