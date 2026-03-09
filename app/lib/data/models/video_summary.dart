class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final int durationSeconds;
  final String summary;
  final List<String> keyPoints;
  final List<SummarySection> sections;
  final String transcriptText;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.summary,
    required this.keyPoints,
    required this.sections,
    required this.transcriptText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get summaryPreview {
    if (summary.length <= 100) return summary;
    return '${summary.substring(0, 100)}...';
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'summary': summary,
      'key_points': keyPoints,
      'sections': sections.map((s) => s.toJson()).toList(),
      'transcript_text': transcriptText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      durationSeconds: json['duration_seconds'] as int,
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['key_points'] as List),
      sections: (json['sections'] as List)
          .map((s) => SummarySection.fromJson(s as Map<String, dynamic>))
          .toList(),
      transcriptText: json['transcript_text'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Create from DB map (sections/key_points stored as comma-separated strings)
  factory VideoSummary.fromDbMap(Map<String, dynamic> map) {
    final keyPointsRaw = map['key_points'] as String? ?? '';
    final keyPoints = keyPointsRaw.isEmpty ? <String>[] : keyPointsRaw.split('|||');

    return VideoSummary(
      videoId: map['video_id'] as String,
      title: map['title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      durationSeconds: map['duration_seconds'] as int,
      summary: map['summary'] as String,
      keyPoints: keyPoints,
      sections: <SummarySection>[],
      transcriptText: map['transcript_text'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'summary': summary,
      'key_points': keyPoints.join('|||'),
      'transcript_text': transcriptText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SummarySection {
  final String title;
  final String content;

  SummarySection({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  factory SummarySection.fromJson(Map<String, dynamic> json) {
    return SummarySection(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}
