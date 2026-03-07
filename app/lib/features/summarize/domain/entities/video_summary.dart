import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_summary.freezed.dart';
part 'video_summary.g.dart';

@freezed
class TranscriptSegment with _$TranscriptSegment {
  const factory TranscriptSegment({
    required String text,
    required double start,
    required double duration,
  }) = _TranscriptSegment;

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSegmentFromJson(json);
}

@freezed
class VideoSummary with _$VideoSummary {
  const factory VideoSummary({
    required String videoId,
    required String title,
    required String thumbnailUrl,
    @Default('') String fullText,
    @Default('') String summary,
    @Default([]) List<TranscriptSegment> transcriptSegments,
    required DateTime createdAt,
  }) = _VideoSummary;

  factory VideoSummary.fromJson(Map<String, dynamic> json) =>
      _$VideoSummaryFromJson(json);
}
