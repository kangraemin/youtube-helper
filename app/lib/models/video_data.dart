class VideoMetadata {
  final String videoId;
  final String title;
  final String thumbnailUrl;

  VideoMetadata({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
  });

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      videoId: json['video_id'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'video_id': videoId,
        'title': title,
        'thumbnail_url': thumbnailUrl,
      };
}

class TranscriptSegment {
  final String text;
  final double start;
  final double duration;

  TranscriptSegment({
    required this.text,
    required this.start,
    required this.duration,
  });

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      text: json['text'] ?? '',
      start: (json['start'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
    );
  }
}

class VideoSummary {
  final VideoMetadata metadata;
  final String fullText;
  final String summary;
  final List<String> keyPoints;
  final List<ChapterSummary> chapters;
  final DateTime createdAt;

  VideoSummary({
    required this.metadata,
    required this.fullText,
    required this.summary,
    required this.keyPoints,
    required this.chapters,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      metadata: VideoMetadata.fromJson(json['metadata'] ?? {}),
      fullText: json['full_text'] ?? '',
      summary: json['summary'] ?? '',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      chapters: (json['chapters'] as List? ?? [])
          .map((c) => ChapterSummary.fromJson(c))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'full_text': fullText,
        'summary': summary,
        'key_points': keyPoints,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };
}

class ChapterSummary {
  final String title;
  final String summary;
  final String startTime;

  ChapterSummary({
    required this.title,
    required this.summary,
    required this.startTime,
  });

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    return ChapterSummary(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      startTime: json['start_time'] ?? '0:00',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'summary': summary,
        'start_time': startTime,
      };
}
