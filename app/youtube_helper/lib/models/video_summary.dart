class VideoTranscript {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String transcript;

  VideoTranscript({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.transcript,
  });

  factory VideoTranscript.fromJson(Map<String, dynamic> json) {
    return VideoTranscript(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      duration: json['duration'] as String,
      transcript: json['transcript'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'transcript': transcript,
    };
  }
}

class VideoSummary {
  final String videoId;
  final String summary;
  final List<String> keyPoints;
  final List<String> actionPoints;

  VideoSummary({
    required this.videoId,
    required this.summary,
    required this.keyPoints,
    required this.actionPoints,
  });

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      videoId: json['video_id'] as String,
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['key_points'] as List),
      actionPoints: List<String>.from(json['action_points'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'summary': summary,
      'key_points': keyPoints,
      'action_points': actionPoints,
    };
  }
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class HistoryEntry {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String summaryPreview;
  final String transcript;
  final String summary;
  final List<String> keyPoints;
  final List<String> actionPoints;
  final DateTime createdAt;

  HistoryEntry({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.summaryPreview,
    required this.transcript,
    required this.summary,
    required this.keyPoints,
    required this.actionPoints,
    required this.createdAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      duration: json['duration'] as String,
      summaryPreview: json['summary_preview'] as String,
      transcript: json['transcript'] as String,
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['key_points'] as List),
      actionPoints: List<String>.from(json['action_points'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'summary_preview': summaryPreview,
      'transcript': transcript,
      'summary': summary,
      'key_points': keyPoints,
      'action_points': actionPoints,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
