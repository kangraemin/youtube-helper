// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TranscriptSegmentImpl _$$TranscriptSegmentImplFromJson(
  Map<String, dynamic> json,
) => _$TranscriptSegmentImpl(
  text: json['text'] as String,
  start: (json['start'] as num).toDouble(),
  duration: (json['duration'] as num).toDouble(),
);

Map<String, dynamic> _$$TranscriptSegmentImplToJson(
  _$TranscriptSegmentImpl instance,
) => <String, dynamic>{
  'text': instance.text,
  'start': instance.start,
  'duration': instance.duration,
};

_$VideoSummaryImpl _$$VideoSummaryImplFromJson(Map<String, dynamic> json) =>
    _$VideoSummaryImpl(
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      fullText: json['fullText'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      transcriptSegments:
          (json['transcriptSegments'] as List<dynamic>?)
              ?.map(
                (e) => TranscriptSegment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$VideoSummaryImplToJson(_$VideoSummaryImpl instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'title': instance.title,
      'thumbnailUrl': instance.thumbnailUrl,
      'fullText': instance.fullText,
      'summary': instance.summary,
      'transcriptSegments': instance.transcriptSegments,
      'createdAt': instance.createdAt.toIso8601String(),
    };
