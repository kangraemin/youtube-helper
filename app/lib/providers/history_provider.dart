import 'package:flutter/foundation.dart';
import '../models/video_summary.dart';
import '../services/database_service.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseService _databaseService;

  List<VideoSummary> _summaries = [];
  bool _isLoading = false;

  HistoryProvider({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  List<VideoSummary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  bool get isEmpty => _summaries.isEmpty;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _summaries = await _databaseService.getAllSummaries();
    } catch (e) {
      _summaries = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSummary(String videoId) async {
    await _databaseService.deleteSummary(videoId);
    _summaries = _summaries.where((s) => s.videoId != videoId).toList();
    notifyListeners();
  }

  Future<VideoSummary?> getSummaryById(String videoId) async {
    return _databaseService.getSummaryById(videoId);
  }
}
