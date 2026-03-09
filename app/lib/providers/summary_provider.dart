import 'package:flutter/foundation.dart';
import '../models/video_summary.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum SummaryState { idle, fetchingTranscript, summarizing, done, error }

class SummaryProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  SummaryState _state = SummaryState.idle;
  VideoSummary? _currentVideo;
  String? _errorMessage;
  double _progress = 0;

  SummaryProvider({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  SummaryState get state => _state;
  VideoSummary? get currentVideo => _currentVideo;
  String? get errorMessage => _errorMessage;
  double get progress => _progress;

  static final RegExp _youtubeRegex = RegExp(
    r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/shorts/)[\w-]+',
  );

  bool isValidYoutubeUrl(String url) => _youtubeRegex.hasMatch(url.trim());

  Future<void> processVideo(String url) async {
    if (!isValidYoutubeUrl(url)) {
      _errorMessage = '올바른 YouTube URL을 입력해주세요.';
      _state = SummaryState.error;
      notifyListeners();
      return;
    }

    try {
      _state = SummaryState.fetchingTranscript;
      _progress = 0.3;
      _errorMessage = null;
      notifyListeners();

      _currentVideo = await _apiService.fetchTranscript(url.trim());
      _progress = 0.5;
      notifyListeners();

      _state = SummaryState.summarizing;
      _progress = 0.65;
      notifyListeners();

      _currentVideo = await _apiService.summarize(_currentVideo!);
      _progress = 1.0;
      notifyListeners();

      await _storageService.saveToHistory(_currentVideo!);

      _state = SummaryState.done;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = SummaryState.error;
      notifyListeners();
    }
  }

  void reset() {
    _state = SummaryState.idle;
    _currentVideo = null;
    _errorMessage = null;
    _progress = 0;
    notifyListeners();
  }
}
