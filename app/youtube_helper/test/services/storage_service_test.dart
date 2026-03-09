import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_helper/services/storage_service.dart';
import 'package:youtube_helper/models/video_summary.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs: prefs);
    });

    test('getHistoryEntries returns empty list initially', () {
      final entries = storageService.getHistoryEntries();
      expect(entries, isEmpty);
    });

    test('saveHistoryEntry and getHistoryEntries work correctly', () async {
      final entry = HistoryEntry(
        videoId: 'test123',
        title: 'Test Video',
        thumbnailUrl: 'https://img.youtube.com/vi/test123/hqdefault.jpg',
        duration: '5:30',
        summaryPreview: 'A preview',
        transcript: 'Full transcript',
        summary: 'Full summary',
        keyPoints: ['Point 1'],
        actionPoints: ['Action 1'],
        createdAt: DateTime(2024, 1, 1),
      );

      await storageService.saveHistoryEntry(entry);
      final entries = storageService.getHistoryEntries();

      expect(entries.length, 1);
      expect(entries.first.videoId, 'test123');
      expect(entries.first.title, 'Test Video');
      expect(entries.first.thumbnailUrl, contains('test123'));
    });

    test('saveHistoryEntry replaces duplicate videoId', () async {
      final entry1 = HistoryEntry(
        videoId: 'test123',
        title: 'First',
        thumbnailUrl: 'url1',
        duration: '1:00',
        summaryPreview: 'preview1',
        transcript: 'transcript1',
        summary: 'summary1',
        keyPoints: [],
        actionPoints: [],
        createdAt: DateTime(2024, 1, 1),
      );
      final entry2 = HistoryEntry(
        videoId: 'test123',
        title: 'Updated',
        thumbnailUrl: 'url2',
        duration: '2:00',
        summaryPreview: 'preview2',
        transcript: 'transcript2',
        summary: 'summary2',
        keyPoints: [],
        actionPoints: [],
        createdAt: DateTime(2024, 1, 2),
      );

      await storageService.saveHistoryEntry(entry1);
      await storageService.saveHistoryEntry(entry2);
      final entries = storageService.getHistoryEntries();

      expect(entries.length, 1);
      expect(entries.first.title, 'Updated');
    });

    test('clearHistory removes all entries', () async {
      final entry = HistoryEntry(
        videoId: 'test123',
        title: 'Test',
        thumbnailUrl: 'url',
        duration: '1:00',
        summaryPreview: 'preview',
        transcript: 'transcript',
        summary: 'summary',
        keyPoints: [],
        actionPoints: [],
        createdAt: DateTime(2024, 1, 1),
      );

      await storageService.saveHistoryEntry(entry);
      await storageService.clearHistory();
      final entries = storageService.getHistoryEntries();

      expect(entries, isEmpty);
    });
  });
}
