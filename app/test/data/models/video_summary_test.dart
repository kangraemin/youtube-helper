import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_helper/data/models/video_summary.dart';

void main() {
  group('VideoSummary', () {
    late VideoSummary summary;

    setUp(() {
      summary = VideoSummary(
        videoId: 'test123',
        title: 'Test Video Title',
        thumbnailUrl: 'https://img.youtube.com/vi/test123/0.jpg',
        durationSeconds: 765,
        summary: 'This is a test summary of the video content.',
        keyPoints: ['Point 1', 'Point 2', 'Point 3'],
        sections: [
          SummarySection(title: 'Intro', content: 'Introduction content'),
          SummarySection(title: 'Main', content: 'Main content'),
        ],
        transcriptText: 'Full transcript text here...',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );
    });

    test('formattedDuration returns correct format', () {
      expect(summary.formattedDuration, '12:45');
    });

    test('formattedDuration handles zero seconds', () {
      final s = VideoSummary(
        videoId: 'v',
        title: 't',
        thumbnailUrl: 'u',
        durationSeconds: 60,
        summary: 's',
        keyPoints: [],
        sections: [],
        transcriptText: 't',
      );
      expect(s.formattedDuration, '1:00');
    });

    test('summaryPreview truncates long text', () {
      final longSummary = VideoSummary(
        videoId: 'v',
        title: 't',
        thumbnailUrl: 'u',
        durationSeconds: 100,
        summary: 'A' * 150,
        keyPoints: [],
        sections: [],
        transcriptText: 't',
      );
      expect(longSummary.summaryPreview.length, 103); // 100 + '...'
      expect(longSummary.summaryPreview.endsWith('...'), isTrue);
    });

    test('summaryPreview returns full text when short', () {
      expect(summary.summaryPreview, summary.summary);
    });

    test('toJson and fromJson round trip', () {
      final json = summary.toJson();
      final restored = VideoSummary.fromJson(json);

      expect(restored.videoId, summary.videoId);
      expect(restored.title, summary.title);
      expect(restored.thumbnailUrl, summary.thumbnailUrl);
      expect(restored.durationSeconds, summary.durationSeconds);
      expect(restored.summary, summary.summary);
      expect(restored.keyPoints, summary.keyPoints);
      expect(restored.sections.length, summary.sections.length);
      expect(restored.transcriptText, summary.transcriptText);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'video_id': 'abc',
        'title': 'My Video',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'duration_seconds': 300,
        'summary': 'A summary',
        'key_points': ['a', 'b'],
        'sections': [
          {'title': 'S1', 'content': 'C1'}
        ],
        'transcript_text': 'transcript',
        'created_at': '2024-01-01T12:00:00.000',
      };

      final result = VideoSummary.fromJson(json);
      expect(result.videoId, 'abc');
      expect(result.title, 'My Video');
      expect(result.keyPoints, ['a', 'b']);
      expect(result.sections.length, 1);
      expect(result.sections.first.title, 'S1');
    });

    test('toDbMap and fromDbMap round trip', () {
      final dbMap = summary.toDbMap();
      final restored = VideoSummary.fromDbMap(dbMap);

      expect(restored.videoId, summary.videoId);
      expect(restored.title, summary.title);
      expect(restored.keyPoints, summary.keyPoints);
      // sections are not stored in DB
      expect(restored.sections, isEmpty);
    });

    test('fromDbMap handles empty key_points', () {
      final dbMap = {
        'video_id': 'v',
        'title': 't',
        'thumbnail_url': 'u',
        'duration_seconds': 100,
        'summary': 's',
        'key_points': '',
        'transcript_text': 't',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final result = VideoSummary.fromDbMap(dbMap);
      expect(result.keyPoints, isEmpty);
    });

    test('createdAt defaults to now when not provided', () {
      final s = VideoSummary(
        videoId: 'v',
        title: 't',
        thumbnailUrl: 'u',
        durationSeconds: 100,
        summary: 's',
        keyPoints: [],
        sections: [],
        transcriptText: 't',
      );
      final now = DateTime.now();
      expect(s.createdAt.difference(now).inSeconds.abs(), lessThan(2));
    });
  });

  group('SummarySection', () {
    test('toJson and fromJson round trip', () {
      final section = SummarySection(title: 'Title', content: 'Content');
      final json = section.toJson();
      final restored = SummarySection.fromJson(json);

      expect(restored.title, 'Title');
      expect(restored.content, 'Content');
    });
  });
}
