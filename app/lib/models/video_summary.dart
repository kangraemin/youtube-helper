class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String transcript;
  final String duration;
  final String summary;
  final List<String> keyPoints;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.transcript,
    required this.duration,
    this.summary = '',
    this.keyPoints = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  VideoSummary copyWith({
    String? summary,
    List<String>? keyPoints,
  }) {
    return VideoSummary(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      transcript: transcript,
      duration: duration,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'transcript': transcript,
        'duration': duration,
        'summary': summary,
        'keyPoints': keyPoints,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VideoSummary.fromJson(Map<String, dynamic> json) => VideoSummary(
        videoId: json['videoId'] as String,
        title: json['title'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        transcript: json['transcript'] as String,
        duration: json['duration'] as String,
        summary: json['summary'] as String? ?? '',
        keyPoints: (json['keyPoints'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}
