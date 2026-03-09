import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_summary.dart';

class StorageService {
  final SharedPreferences prefs;
  static const String _historyKey = 'history_entries';

  StorageService({required this.prefs});

  Future<void> saveHistoryEntry(HistoryEntry entry) async {
    final entries = getHistoryEntries();
    entries.removeWhere((e) => e.videoId == entry.videoId);
    entries.insert(0, entry);
    final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  List<HistoryEntry> getHistoryEntries() {
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    return jsonList
        .map(
          (json) =>
              HistoryEntry.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> clearHistory() async {
    await prefs.remove(_historyKey);
  }
}
