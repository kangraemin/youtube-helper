import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/video_summary.dart';

void main() {
  group('VideoSummary', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);
    final testSummary = VideoSummary(
      videoId: 'abc123',
      title: 'Test Video Title',
      thumbnailUrl: 'https://img.youtube.com/vi/abc123/0.jpg',
      duration: '10:30',
      transcript: 'Full transcript text here',
      summary: 'This is a summary of the video.',
      keyPoints: ['Point 1', 'Point 2', 'Point 3'],
      transcriptPreview: 'First few lines of transcript...',
      language: 'ko',
      createdAt: testDate,
    );

    test('should create a VideoSummary with all fields', () {
      expect(testSummary.videoId, 'abc123');
      expect(testSummary.title, 'Test Video Title');
      expect(testSummary.thumbnailUrl, 'https://img.youtube.com/vi/abc123/0.jpg');
      expect(testSummary.duration, '10:30');
      expect(testSummary.transcript, 'Full transcript text here');
      expect(testSummary.summary, 'This is a summary of the video.');
      expect(testSummary.keyPoints, ['Point 1', 'Point 2', 'Point 3']);
      expect(testSummary.transcriptPreview, 'First few lines of transcript...');
      expect(testSummary.language, 'ko');
      expect(testSummary.createdAt, testDate);
    });

    test('toMap should convert to a valid map', () {
      final map = testSummary.toMap();
      expect(map['video_id'], 'abc123');
      expect(map['title'], 'Test Video Title');
      expect(map['thumbnail_url'], 'https://img.youtube.com/vi/abc123/0.jpg');
      expect(map['duration'], '10:30');
      expect(map['summary'], 'This is a summary of the video.');
      expect(jsonDecode(map['key_points']), ['Point 1', 'Point 2', 'Point 3']);
      expect(map['language'], 'ko');
      expect(map['created_at'], testDate.toIso8601String());
    });

    test('fromMap should create VideoSummary from map', () {
      final map = testSummary.toMap();
      final restored = VideoSummary.fromMap(map);
      expect(restored.videoId, testSummary.videoId);
      expect(restored.title, testSummary.title);
      expect(restored.summary, testSummary.summary);
      expect(restored.keyPoints, testSummary.keyPoints);
      expect(restored.language, testSummary.language);
      expect(restored.createdAt, testSummary.createdAt);
    });

    test('fromJson should create VideoSummary from JSON', () {
      final json = {
        'video_id': 'xyz789',
        'title': 'JSON Video',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'duration': '5:00',
        'transcript': 'Some transcript',
        'summary': 'JSON summary',
        'key_points': ['A', 'B'],
        'transcript_preview': 'Preview...',
        'language': 'en',
        'created_at': '2024-01-15T10:30:00.000',
      };
      final summary = VideoSummary.fromJson(json);
      expect(summary.videoId, 'xyz789');
      expect(summary.title, 'JSON Video');
      expect(summary.keyPoints, ['A', 'B']);
      expect(summary.language, 'en');
    });

    test('fromJson should handle missing optional fields', () {
      final json = {
        'video_id': 'xyz789',
        'title': 'Minimal Video',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'summary': 'Minimal summary',
        'key_points': ['A'],
      };
      final summary = VideoSummary.fromJson(json);
      expect(summary.duration, '');
      expect(summary.transcript, '');
      expect(summary.transcriptPreview, '');
      expect(summary.language, 'ko');
    });

    test('copyWith should create a copy with updated fields', () {
      final copy = testSummary.copyWith(title: 'Updated Title', language: 'en');
      expect(copy.title, 'Updated Title');
      expect(copy.language, 'en');
      expect(copy.videoId, testSummary.videoId);
      expect(copy.summary, testSummary.summary);
    });

    test('toMap and fromMap should be reversible', () {
      final map = testSummary.toMap();
      final restored = VideoSummary.fromMap(map);
      final map2 = restored.toMap();
      expect(map, map2);
    });
  });
}
