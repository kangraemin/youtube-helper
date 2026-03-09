import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_summary.dart';

class StorageService {
  static const String _historyKey = 'video_history';

  Future<List<VideoSummary>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    return jsonList
        .map((s) =>
            VideoSummary.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveToHistory(VideoSummary video) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    // Remove existing entry with same video_id
    history.removeWhere((v) => v.videoId == video.videoId);
    // Add new entry at the beginning
    history.insert(0, video);

    final jsonList = history.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<void> removeFromHistory(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.removeWhere((v) => v.videoId == videoId);
    final jsonList = history.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
