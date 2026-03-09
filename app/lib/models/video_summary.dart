class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String summary;
  final List<String> keyPoints;
  final List<String> tips;
  final String? fullText;
  final List<TranscriptSegment>? segments;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.summary,
    required this.keyPoints,
    required this.tips,
    this.fullText,
    this.segments,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory VideoSummary.fromSummaryResponse(
    Map<String, dynamic> json, {
    String? fullText,
    List<TranscriptSegment>? segments,
  }) {
    return VideoSummary(
      videoId: json['video_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      keyPoints: (json['key_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tips: (json['tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      fullText: fullText,
      segments: segments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'summary': summary,
      'key_points': keyPoints,
      'tips': tips,
      'full_text': fullText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TranscriptSegment {
  final double start;
  final double duration;
  final String text;

  TranscriptSegment({
    required this.start,
    required this.duration,
    required this.text,
  });

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      start: (json['start'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
    );
  }

  String get formattedTime {
    final minutes = (start ~/ 60).toString().padLeft(2, '0');
    final seconds = (start % 60).truncate().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
