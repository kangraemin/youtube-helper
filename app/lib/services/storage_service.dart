import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_summary.dart';

class StorageService {
  static const String _historyCacheKey = 'video_history';
  static const String _serverUrlKey = 'server_url';

  Future<List<VideoSummary>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyCacheKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => VideoSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToHistory(VideoSummary summary) async {
    final history = await getHistory();
    // Remove duplicate if exists
    history.removeWhere((item) => item.videoId == summary.videoId);
    // Add to front
    history.insert(0, summary);
    // Keep max 50 items
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    await _saveHistory(history);
  }

  Future<void> _saveHistory(List<VideoSummary> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_historyCacheKey, jsonString);
  }

  Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? 'http://localhost:8000';
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }
}
