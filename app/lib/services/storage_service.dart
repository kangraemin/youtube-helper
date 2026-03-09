import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_summary.dart';

class StorageService {
  static const String _historyKey = 'video_history';

  Future<List<VideoSummary>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => VideoSummary.fromJson(e)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveToHistory(VideoSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.removeWhere((item) => item.videoId == summary.videoId);
    history.insert(0, summary);

    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    final jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, jsonString);
  }

  Future<void> removeFromHistory(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((item) => item.videoId == videoId);
    final jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, jsonString);
  }
}
