import 'package:flutter/foundation.dart';
import '../models/video_summary.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<VideoSummary> _history = [];
  bool _isLoading = false;

  HistoryProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  List<VideoSummary> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _history = await _storageService.loadHistory();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeItem(String videoId) async {
    await _storageService.removeFromHistory(videoId);
    _history.removeWhere((v) => v.videoId == videoId);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _storageService.clearHistory();
    _history = [];
    notifyListeners();
  }
}
