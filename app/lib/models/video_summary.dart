import 'dart:convert';

class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String transcript;
  final String summary;
  final List<String> keyPoints;
  final String transcriptPreview;
  final String language;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.transcript,
    required this.summary,
    required this.keyPoints,
    required this.transcriptPreview,
    required this.language,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'transcript': transcript,
      'summary': summary,
      'key_points': jsonEncode(keyPoints),
      'transcript_preview': transcriptPreview,
      'language': language,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VideoSummary.fromMap(Map<String, dynamic> map) {
    return VideoSummary(
      videoId: map['video_id'] as String,
      title: map['title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      duration: map['duration'] as String,
      transcript: map['transcript'] as String,
      summary: map['summary'] as String,
      keyPoints: List<String>.from(jsonDecode(map['key_points'] as String)),
      transcriptPreview: map['transcript_preview'] as String,
      language: map['language'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      duration: json['duration'] as String? ?? '',
      transcript: json['transcript'] as String? ?? '',
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['key_points'] as List),
      transcriptPreview: json['transcript_preview'] as String? ?? '',
      language: json['language'] as String? ?? 'ko',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  VideoSummary copyWith({
    String? videoId,
    String? title,
    String? thumbnailUrl,
    String? duration,
    String? transcript,
    String? summary,
    List<String>? keyPoints,
    String? transcriptPreview,
    String? language,
    DateTime? createdAt,
  }) {
    return VideoSummary(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      transcriptPreview: transcriptPreview ?? this.transcriptPreview,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
