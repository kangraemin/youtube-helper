// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SummaryEntityImpl _$$SummaryEntityImplFromJson(Map<String, dynamic> json) =>
    _$SummaryEntityImpl(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      videoTitle: json['videoTitle'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      transcript: json['transcript'] as String,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      videoUrl: json['videoUrl'] as String,
    );

Map<String, dynamic> _$$SummaryEntityImplToJson(_$SummaryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'videoTitle': instance.videoTitle,
      'thumbnailUrl': instance.thumbnailUrl,
      'transcript': instance.transcript,
      'summary': instance.summary,
      'createdAt': instance.createdAt.toIso8601String(),
      'videoUrl': instance.videoUrl,
    };
