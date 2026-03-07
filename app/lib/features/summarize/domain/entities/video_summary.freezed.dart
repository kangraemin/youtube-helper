// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TranscriptSegment _$TranscriptSegmentFromJson(Map<String, dynamic> json) {
  return _TranscriptSegment.fromJson(json);
}

/// @nodoc
mixin _$TranscriptSegment {
  String get text => throw _privateConstructorUsedError;
  double get start => throw _privateConstructorUsedError;
  double get duration => throw _privateConstructorUsedError;

  /// Serializes this TranscriptSegment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranscriptSegmentCopyWith<TranscriptSegment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptSegmentCopyWith<$Res> {
  factory $TranscriptSegmentCopyWith(
    TranscriptSegment value,
    $Res Function(TranscriptSegment) then,
  ) = _$TranscriptSegmentCopyWithImpl<$Res, TranscriptSegment>;
  @useResult
  $Res call({String text, double start, double duration});
}

/// @nodoc
class _$TranscriptSegmentCopyWithImpl<$Res, $Val extends TranscriptSegment>
    implements $TranscriptSegmentCopyWith<$Res> {
  _$TranscriptSegmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? start = null,
    Object? duration = null,
  }) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            start: null == start
                ? _value.start
                : start // ignore: cast_nullable_to_non_nullable
                      as double,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranscriptSegmentImplCopyWith<$Res>
    implements $TranscriptSegmentCopyWith<$Res> {
  factory _$$TranscriptSegmentImplCopyWith(
    _$TranscriptSegmentImpl value,
    $Res Function(_$TranscriptSegmentImpl) then,
  ) = __$$TranscriptSegmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, double start, double duration});
}

/// @nodoc
class __$$TranscriptSegmentImplCopyWithImpl<$Res>
    extends _$TranscriptSegmentCopyWithImpl<$Res, _$TranscriptSegmentImpl>
    implements _$$TranscriptSegmentImplCopyWith<$Res> {
  __$$TranscriptSegmentImplCopyWithImpl(
    _$TranscriptSegmentImpl _value,
    $Res Function(_$TranscriptSegmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? start = null,
    Object? duration = null,
  }) {
    return _then(
      _$TranscriptSegmentImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        start: null == start
            ? _value.start
            : start // ignore: cast_nullable_to_non_nullable
                  as double,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranscriptSegmentImpl implements _TranscriptSegment {
  const _$TranscriptSegmentImpl({
    required this.text,
    required this.start,
    required this.duration,
  });

  factory _$TranscriptSegmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranscriptSegmentImplFromJson(json);

  @override
  final String text;
  @override
  final double start;
  @override
  final double duration;

  @override
  String toString() {
    return 'TranscriptSegment(text: $text, start: $start, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptSegmentImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, start, duration);

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptSegmentImplCopyWith<_$TranscriptSegmentImpl> get copyWith =>
      __$$TranscriptSegmentImplCopyWithImpl<_$TranscriptSegmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TranscriptSegmentImplToJson(this);
  }
}

abstract class _TranscriptSegment implements TranscriptSegment {
  const factory _TranscriptSegment({
    required final String text,
    required final double start,
    required final double duration,
  }) = _$TranscriptSegmentImpl;

  factory _TranscriptSegment.fromJson(Map<String, dynamic> json) =
      _$TranscriptSegmentImpl.fromJson;

  @override
  String get text;
  @override
  double get start;
  @override
  double get duration;

  /// Create a copy of TranscriptSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranscriptSegmentImplCopyWith<_$TranscriptSegmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoSummary _$VideoSummaryFromJson(Map<String, dynamic> json) {
  return _VideoSummary.fromJson(json);
}

/// @nodoc
mixin _$VideoSummary {
  String get videoId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  String get fullText => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  List<TranscriptSegment> get transcriptSegments =>
      throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this VideoSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoSummaryCopyWith<VideoSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoSummaryCopyWith<$Res> {
  factory $VideoSummaryCopyWith(
    VideoSummary value,
    $Res Function(VideoSummary) then,
  ) = _$VideoSummaryCopyWithImpl<$Res, VideoSummary>;
  @useResult
  $Res call({
    String videoId,
    String title,
    String thumbnailUrl,
    String fullText,
    String summary,
    List<TranscriptSegment> transcriptSegments,
    DateTime createdAt,
  });
}

/// @nodoc
class _$VideoSummaryCopyWithImpl<$Res, $Val extends VideoSummary>
    implements $VideoSummaryCopyWith<$Res> {
  _$VideoSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? title = null,
    Object? thumbnailUrl = null,
    Object? fullText = null,
    Object? summary = null,
    Object? transcriptSegments = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            videoId: null == videoId
                ? _value.videoId
                : videoId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailUrl: null == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            fullText: null == fullText
                ? _value.fullText
                : fullText // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            transcriptSegments: null == transcriptSegments
                ? _value.transcriptSegments
                : transcriptSegments // ignore: cast_nullable_to_non_nullable
                      as List<TranscriptSegment>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VideoSummaryImplCopyWith<$Res>
    implements $VideoSummaryCopyWith<$Res> {
  factory _$$VideoSummaryImplCopyWith(
    _$VideoSummaryImpl value,
    $Res Function(_$VideoSummaryImpl) then,
  ) = __$$VideoSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String videoId,
    String title,
    String thumbnailUrl,
    String fullText,
    String summary,
    List<TranscriptSegment> transcriptSegments,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$VideoSummaryImplCopyWithImpl<$Res>
    extends _$VideoSummaryCopyWithImpl<$Res, _$VideoSummaryImpl>
    implements _$$VideoSummaryImplCopyWith<$Res> {
  __$$VideoSummaryImplCopyWithImpl(
    _$VideoSummaryImpl _value,
    $Res Function(_$VideoSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videoId = null,
    Object? title = null,
    Object? thumbnailUrl = null,
    Object? fullText = null,
    Object? summary = null,
    Object? transcriptSegments = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$VideoSummaryImpl(
        videoId: null == videoId
            ? _value.videoId
            : videoId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailUrl: null == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        fullText: null == fullText
            ? _value.fullText
            : fullText // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        transcriptSegments: null == transcriptSegments
            ? _value._transcriptSegments
            : transcriptSegments // ignore: cast_nullable_to_non_nullable
                  as List<TranscriptSegment>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoSummaryImpl implements _VideoSummary {
  const _$VideoSummaryImpl({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    this.fullText = '',
    this.summary = '',
    final List<TranscriptSegment> transcriptSegments = const [],
    required this.createdAt,
  }) : _transcriptSegments = transcriptSegments;

  factory _$VideoSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoSummaryImplFromJson(json);

  @override
  final String videoId;
  @override
  final String title;
  @override
  final String thumbnailUrl;
  @override
  @JsonKey()
  final String fullText;
  @override
  @JsonKey()
  final String summary;
  final List<TranscriptSegment> _transcriptSegments;
  @override
  @JsonKey()
  List<TranscriptSegment> get transcriptSegments {
    if (_transcriptSegments is EqualUnmodifiableListView)
      return _transcriptSegments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transcriptSegments);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'VideoSummary(videoId: $videoId, title: $title, thumbnailUrl: $thumbnailUrl, fullText: $fullText, summary: $summary, transcriptSegments: $transcriptSegments, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoSummaryImpl &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.fullText, fullText) ||
                other.fullText == fullText) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._transcriptSegments,
              _transcriptSegments,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    videoId,
    title,
    thumbnailUrl,
    fullText,
    summary,
    const DeepCollectionEquality().hash(_transcriptSegments),
    createdAt,
  );

  /// Create a copy of VideoSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoSummaryImplCopyWith<_$VideoSummaryImpl> get copyWith =>
      __$$VideoSummaryImplCopyWithImpl<_$VideoSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoSummaryImplToJson(this);
  }
}

abstract class _VideoSummary implements VideoSummary {
  const factory _VideoSummary({
    required final String videoId,
    required final String title,
    required final String thumbnailUrl,
    final String fullText,
    final String summary,
    final List<TranscriptSegment> transcriptSegments,
    required final DateTime createdAt,
  }) = _$VideoSummaryImpl;

  factory _VideoSummary.fromJson(Map<String, dynamic> json) =
      _$VideoSummaryImpl.fromJson;

  @override
  String get videoId;
  @override
  String get title;
  @override
  String get thumbnailUrl;
  @override
  String get fullText;
  @override
  String get summary;
  @override
  List<TranscriptSegment> get transcriptSegments;
  @override
  DateTime get createdAt;

  /// Create a copy of VideoSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoSummaryImplCopyWith<_$VideoSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
