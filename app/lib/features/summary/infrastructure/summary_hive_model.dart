import 'package:hive_flutter/hive_flutter.dart';

import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';

class SummaryHiveModel extends HiveObject {
  final String id;
  final String videoId;
  final String videoTitle;
  final String thumbnailUrl;
  final String transcript;
  final String summary;
  final DateTime createdAt;
  final String videoUrl;

  SummaryHiveModel({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.thumbnailUrl,
    required this.transcript,
    required this.summary,
    required this.createdAt,
    required this.videoUrl,
  });

  factory SummaryHiveModel.fromEntity(SummaryEntity entity) {
    return SummaryHiveModel(
      id: entity.id,
      videoId: entity.videoId,
      videoTitle: entity.videoTitle,
      thumbnailUrl: entity.thumbnailUrl,
      transcript: entity.transcript,
      summary: entity.summary,
      createdAt: entity.createdAt,
      videoUrl: entity.videoUrl,
    );
  }

  SummaryEntity toEntity() {
    return SummaryEntity(
      id: id,
      videoId: videoId,
      videoTitle: videoTitle,
      thumbnailUrl: thumbnailUrl,
      transcript: transcript,
      summary: summary,
      createdAt: createdAt,
      videoUrl: videoUrl,
    );
  }
}

class SummaryHiveModelAdapter extends TypeAdapter<SummaryHiveModel> {
  @override
  final int typeId = 0;

  @override
  SummaryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SummaryHiveModel(
      id: fields[0] as String,
      videoId: fields[1] as String,
      videoTitle: fields[2] as String,
      thumbnailUrl: fields[3] as String,
      transcript: fields[4] as String,
      summary: fields[5] as String,
      createdAt: fields[6] as DateTime,
      videoUrl: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SummaryHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.videoId)
      ..writeByte(2)
      ..write(obj.videoTitle)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.transcript)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.videoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
