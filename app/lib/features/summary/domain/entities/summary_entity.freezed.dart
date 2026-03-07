// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SummaryEntity _$SummaryEntityFromJson(Map<String, dynamic> json) {
  return _SummaryEntity.fromJson(json);
}

/// @nodoc
mixin _$SummaryEntity {
  String get id => throw _privateConstructorUsedError;
  String get videoId => throw _privateConstructorUsedError;
  String get videoTitle => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  String get transcript => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get videoUrl => throw _privateConstructorUsedError;

  /// Serializes this SummaryEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SummaryEntityCopyWith<SummaryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryEntityCopyWith<$Res> {
  factory $SummaryEntityCopyWith(
    SummaryEntity value,
    $Res Function(SummaryEntity) then,
  ) = _$SummaryEntityCopyWithImpl<$Res, SummaryEntity>;
  @useResult
  $Res call({
    String id,
    String videoId,
    String videoTitle,
    String thumbnailUrl,
    String transcript,
    String summary,
    DateTime createdAt,
    String videoUrl,
  });
}

/// @nodoc
class _$SummaryEntityCopyWithImpl<$Res, $Val extends SummaryEntity>
    implements $SummaryEntityCopyWith<$Res> {
  _$SummaryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? videoTitle = null,
    Object? thumbnailUrl = null,
    Object? transcript = null,
    Object? summary = null,
    Object? createdAt = null,
    Object? videoUrl = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            videoId: null == videoId
                ? _value.videoId
                : videoId // ignore: cast_nullable_to_non_nullable
                      as String,
            videoTitle: null == videoTitle
                ? _value.videoTitle
                : videoTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailUrl: null == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            transcript: null == transcript
                ? _value.transcript
                : transcript // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            videoUrl: null == videoUrl
                ? _value.videoUrl
                : videoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SummaryEntityImplCopyWith<$Res>
    implements $SummaryEntityCopyWith<$Res> {
  factory _$$SummaryEntityImplCopyWith(
    _$SummaryEntityImpl value,
    $Res Function(_$SummaryEntityImpl) then,
  ) = __$$SummaryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String videoId,
    String videoTitle,
    String thumbnailUrl,
    String transcript,
    String summary,
    DateTime createdAt,
    String videoUrl,
  });
}

/// @nodoc
class __$$SummaryEntityImplCopyWithImpl<$Res>
    extends _$SummaryEntityCopyWithImpl<$Res, _$SummaryEntityImpl>
    implements _$$SummaryEntityImplCopyWith<$Res> {
  __$$SummaryEntityImplCopyWithImpl(
    _$SummaryEntityImpl _value,
    $Res Function(_$SummaryEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? videoTitle = null,
    Object? thumbnailUrl = null,
    Object? transcript = null,
    Object? summary = null,
    Object? createdAt = null,
    Object? videoUrl = null,
  }) {
    return _then(
      _$SummaryEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        videoId: null == videoId
            ? _value.videoId
            : videoId // ignore: cast_nullable_to_non_nullable
                  as String,
        videoTitle: null == videoTitle
            ? _value.videoTitle
            : videoTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailUrl: null == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        transcript: null == transcript
            ? _value.transcript
            : transcript // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        videoUrl: null == videoUrl
            ? _value.videoUrl
            : videoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SummaryEntityImpl implements _SummaryEntity {
  const _$SummaryEntityImpl({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.thumbnailUrl,
    required this.transcript,
    required this.summary,
    required this.createdAt,
    required this.videoUrl,
  });

  factory _$SummaryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SummaryEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String videoId;
  @override
  final String videoTitle;
  @override
  final String thumbnailUrl;
  @override
  final String transcript;
  @override
  final String summary;
  @override
  final DateTime createdAt;
  @override
  final String videoUrl;

  @override
  String toString() {
    return 'SummaryEntity(id: $id, videoId: $videoId, videoTitle: $videoTitle, thumbnailUrl: $thumbnailUrl, transcript: $transcript, summary: $summary, createdAt: $createdAt, videoUrl: $videoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.videoTitle, videoTitle) ||
                other.videoTitle == videoTitle) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    videoId,
    videoTitle,
    thumbnailUrl,
    transcript,
    summary,
    createdAt,
    videoUrl,
  );

  /// Create a copy of SummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryEntityImplCopyWith<_$SummaryEntityImpl> get copyWith =>
      __$$SummaryEntityImplCopyWithImpl<_$SummaryEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SummaryEntityImplToJson(this);
  }
}

abstract class _SummaryEntity implements SummaryEntity {
  const factory _SummaryEntity({
    required final String id,
    required final String videoId,
    required final String videoTitle,
    required final String thumbnailUrl,
    required final String transcript,
    required final String summary,
    required final DateTime createdAt,
    required final String videoUrl,
  }) = _$SummaryEntityImpl;

  factory _SummaryEntity.fromJson(Map<String, dynamic> json) =
      _$SummaryEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get videoId;
  @override
  String get videoTitle;
  @override
  String get thumbnailUrl;
  @override
  String get transcript;
  @override
  String get summary;
  @override
  DateTime get createdAt;
  @override
  String get videoUrl;

  /// Create a copy of SummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SummaryEntityImplCopyWith<_$SummaryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
