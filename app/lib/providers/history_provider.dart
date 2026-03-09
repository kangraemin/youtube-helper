import 'package:flutter/foundation.dart';
import '../data/local/database_helper.dart';
import '../data/models/video_summary.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;

  List<VideoSummary> _summaries = [];
  bool _isLoading = false;

  HistoryProvider({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  List<VideoSummary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  bool get isEmpty => _summaries.isEmpty;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _summaries = await _dbHelper.getAllSummaries();
    } catch (e) {
      _summaries = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSummary(String videoId) async {
    await _dbHelper.deleteSummary(videoId);
    _summaries.removeWhere((s) => s.videoId == videoId);
    notifyListeners();
  }
}
