import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';

class StorageService {
  static const _historyBox = 'history';

  Box get _box => Hive.box(_historyBox);

  List<VideoSummary> getAll() {
    final items = <VideoSummary>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw != null) {
        items.add(
          VideoSummary.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>,
          ),
        );
      }
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> save(VideoSummary summary) async {
    await _box.put(summary.videoId, jsonEncode(summary.toJson()));
  }

  Future<void> delete(String videoId) async {
    await _box.delete(videoId);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  VideoSummary? get(String videoId) {
    final raw = _box.get(videoId);
    if (raw == null) return null;
    return VideoSummary.fromJson(
      jsonDecode(raw as String) as Map<String, dynamic>,
    );
  }
}
