import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_summary.dart';

class StorageService {
  static const String _historyKey = 'summary_history';

  Future<List<VideoSummary>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_historyKey) ?? [];
    return data.map((e) => VideoSummary.decode(e)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveSummary(VideoSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_historyKey) ?? [];

    // Remove existing entry for same video
    data.removeWhere((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['videoId'] == summary.videoId;
    });

    data.add(summary.encode());
    await prefs.setStringList(_historyKey, data);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
