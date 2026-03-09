import 'dart:convert';

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
      text: json['text'] as String,
      start: (json['start'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'start': start,
        'duration': duration,
      };
}

class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final List<TranscriptSegment> transcript;
  final String fullText;
  final String language;
  final String? summary;
  final List<String>? keyPoints;
  final String? fullSummary;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.transcript,
    required this.fullText,
    required this.language,
    this.summary,
    this.keyPoints,
    this.fullSummary,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  VideoSummary copyWith({
    String? summary,
    List<String>? keyPoints,
    String? fullSummary,
  }) {
    return VideoSummary(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      transcript: transcript,
      fullText: fullText,
      language: language,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      fullSummary: fullSummary ?? this.fullSummary,
      createdAt: createdAt,
    );
  }

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      transcript: (json['transcript'] as List<dynamic>)
          .map((e) => TranscriptSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      fullText: json['full_text'] as String,
      language: json['language'] as String,
      summary: json['summary'] as String?,
      keyPoints: (json['key_points'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      fullSummary: json['full_summary'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'video_id': videoId,
        'title': title,
        'thumbnail_url': thumbnailUrl,
        'transcript': transcript.map((e) => e.toJson()).toList(),
        'full_text': fullText,
        'language': language,
        'summary': summary,
        'key_points': keyPoints,
        'full_summary': fullSummary,
        'created_at': createdAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory VideoSummary.fromJsonString(String jsonString) {
    return VideoSummary.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
