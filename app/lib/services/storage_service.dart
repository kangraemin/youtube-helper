import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_data.dart';

class StorageService {
  static const String _historyKey = 'video_history';

  static Future<void> saveVideoSummary(VideoSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Remove duplicate if exists
    history.removeWhere(
      (item) => item.metadata.videoId == summary.metadata.videoId,
    );

    // Add to front
    history.insert(0, summary);

    // Keep max 50 items
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    final jsonList = history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  static Future<List<VideoSummary>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];

    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return VideoSummary.fromJson(map);
    }).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
