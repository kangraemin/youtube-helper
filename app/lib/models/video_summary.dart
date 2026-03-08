import 'dart:convert';

class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String transcript;
  final String summary;
  final List<String> keyPoints;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.transcript,
    required this.summary,
    required this.keyPoints,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get thumbnailImageUrl =>
      thumbnailUrl.isNotEmpty
          ? thumbnailUrl
          : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'thumbnailUrl': thumbnailUrl,
    'transcript': transcript,
    'summary': summary,
    'keyPoints': keyPoints,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VideoSummary.fromJson(Map<String, dynamic> json) => VideoSummary(
    videoId: json['videoId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    transcript: json['transcript'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
    keyPoints: (json['keyPoints'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );

  String encode() => jsonEncode(toJson());

  factory VideoSummary.decode(String source) =>
      VideoSummary.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
