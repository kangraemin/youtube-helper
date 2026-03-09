import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/history_item.dart';
import '../models/video_summary.dart';

class HistoryProvider extends ChangeNotifier {
  static const String _boxName = 'history';
  Box<HistoryItem>? _box;

  List<HistoryItem> get items {
    if (_box == null || !_box!.isOpen) return [];
    final list = _box!.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> init() async {
    _box = await Hive.openBox<HistoryItem>(_boxName);
    notifyListeners();
  }

  Future<void> addFromSummary(VideoSummary summary) async {
    if (_box == null) return;

    // Remove existing entry for same video
    final existing = _box!.values
        .where((item) => item.videoId == summary.videoId)
        .toList();
    for (final item in existing) {
      await item.delete();
    }

    final historyItem = HistoryItem(
      videoId: summary.videoId,
      title: summary.title,
      thumbnailUrl: summary.thumbnailUrl,
      summary: summary.summary,
      keyPoints: summary.keyPoints,
      tips: summary.tips,
      fullText: summary.fullText,
    );

    await _box!.add(historyItem);
    notifyListeners();
  }

  Future<void> removeItem(HistoryItem item) async {
    await item.delete();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box?.clear();
    notifyListeners();
  }
}
