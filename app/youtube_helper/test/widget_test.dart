import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_helper/models/video_summary.dart';

void main() {
  group('VideoTranscript', () {
    test('fromJson creates correct object', () {
      final json = {
        'video_id': 'abc123',
        'title': 'Test Title',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'duration': '10:30',
        'transcript': 'Hello world',
      };

      final transcript = VideoTranscript.fromJson(json);

      expect(transcript.videoId, 'abc123');
      expect(transcript.title, 'Test Title');
      expect(transcript.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(transcript.duration, '10:30');
      expect(transcript.transcript, 'Hello world');
    });

    test('toJson creates correct map', () {
      final transcript = VideoTranscript(
        videoId: 'abc123',
        title: 'Test',
        thumbnailUrl: 'url',
        duration: '5:00',
        transcript: 'text',
      );

      final json = transcript.toJson();
      expect(json['video_id'], 'abc123');
      expect(json['title'], 'Test');
    });
  });

  group('VideoSummary', () {
    test('fromJson creates correct object', () {
      final json = {
        'video_id': 'abc123',
        'summary': 'A summary',
        'key_points': ['point1', 'point2'],
        'action_points': ['action1'],
      };

      final summary = VideoSummary.fromJson(json);

      expect(summary.videoId, 'abc123');
      expect(summary.summary, 'A summary');
      expect(summary.keyPoints.length, 2);
      expect(summary.actionPoints.length, 1);
    });
  });

  group('HistoryEntry', () {
    test('fromJson and toJson roundtrip', () {
      final entry = HistoryEntry(
        videoId: 'v1',
        title: 'Title',
        thumbnailUrl: 'thumb',
        duration: '3:00',
        summaryPreview: 'preview',
        transcript: 'transcript',
        summary: 'summary',
        keyPoints: ['k1'],
        actionPoints: ['a1'],
        createdAt: DateTime(2024, 6, 15),
      );

      final json = entry.toJson();
      final restored = HistoryEntry.fromJson(json);

      expect(restored.videoId, 'v1');
      expect(restored.title, 'Title');
      expect(restored.thumbnailUrl, 'thumb');
      expect(restored.keyPoints, ['k1']);
      expect(restored.createdAt.year, 2024);
    });
  });
}
