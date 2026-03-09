class Section {
  final String title;
  final String content;

  Section({required this.title, required this.content});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}

class VideoSummary {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String transcript;
  final String summary;
  final List<String> keyPoints;
  final List<Section> sections;
  final String language;
  final DateTime createdAt;

  VideoSummary({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.transcript,
    required this.summary,
    required this.keyPoints,
    required this.sections,
    this.language = 'ko',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      videoId: json['video_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      transcript: json['transcript'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      keyPoints: (json['key_points'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      language: json['language'] as String? ?? 'ko',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'transcript': transcript,
      'summary': summary,
      'key_points': keyPoints,
      'sections': sections.map((s) => s.toJson()).toList(),
      'language': language,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
