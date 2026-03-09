class Transcript {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final int durationSeconds;
  final String language;
  final List<TranscriptSegment> segments;
  final String transcriptText;

  Transcript({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.language,
    required this.segments,
    required this.transcriptText,
  });

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      durationSeconds: json['duration_seconds'] as int,
      language: json['language'] as String,
      segments: (json['segments'] as List)
          .map((s) => TranscriptSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
      transcriptText: json['transcript_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'language': language,
      'segments': segments.map((s) => s.toJson()).toList(),
      'transcript_text': transcriptText,
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

  String get formattedStart {
    final totalSeconds = start.toInt();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      start: (json['start'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'duration': duration,
      'text': text,
    };
  }
}
