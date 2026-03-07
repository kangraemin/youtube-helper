import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary_entity.freezed.dart';
part 'summary_entity.g.dart';

@freezed
class SummaryEntity with _$SummaryEntity {
  const factory SummaryEntity({
    required String id,
    required String videoId,
    required String videoTitle,
    required String thumbnailUrl,
    required String transcript,
    required String summary,
    required DateTime createdAt,
    required String videoUrl,
  }) = _SummaryEntity;

  factory SummaryEntity.fromJson(Map<String, dynamic> json) =>
      _$SummaryEntityFromJson(json);
}
