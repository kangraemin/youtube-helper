import 'package:hive/hive.dart';

class HistoryItem extends HiveObject {
  String videoId;
  String title;
  String thumbnailUrl;
  String summary;
  List<String> keyPoints;
  List<String> tips;
  String? fullText;
  DateTime createdAt;

  HistoryItem({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.summary,
    required this.keyPoints,
    required this.tips,
    this.fullText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 0;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return HistoryItem(
      videoId: fields[0] as String,
      title: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      summary: fields[3] as String,
      keyPoints: (fields[4] as List).cast<String>(),
      tips: (fields[5] as List).cast<String>(),
      fullText: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.videoId);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.thumbnailUrl);
    writer.writeByte(3);
    writer.write(obj.summary);
    writer.writeByte(4);
    writer.write(obj.keyPoints);
    writer.writeByte(5);
    writer.write(obj.tips);
    writer.writeByte(6);
    writer.write(obj.fullText);
    writer.writeByte(7);
    writer.write(obj.createdAt);
  }
}
