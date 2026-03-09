import 'dart:convert';

class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnail;
  final String transcript;
  final String duration;
  String? summary;
  List<String>? keyPoints;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.transcript,
    required this.duration,
    this.summary,
    this.keyPoints,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail': thumbnail,
      'transcript': transcript,
      'duration': duration,
      'summary': summary,
      'key_points': keyPoints,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String,
      transcript: json['transcript'] as String,
      duration: json['duration'] as String,
      summary: json['summary'] as String?,
      keyPoints: (json['key_points'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory VideoSummary.fromJsonString(String jsonString) {
    return VideoSummary.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
