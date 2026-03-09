import 'package:flutter/foundation.dart';
import '../data/api/api_client.dart';
import '../data/local/database_helper.dart';
import '../data/models/video_summary.dart';

enum SummaryState { idle, loading, success, error }

class SummaryProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final DatabaseHelper _dbHelper;

  SummaryState _state = SummaryState.idle;
  VideoSummary? _currentSummary;
  String? _errorMessage;
  double _progress = 0.0;

  SummaryProvider({
    required ApiClient apiClient,
    required DatabaseHelper dbHelper,
  })  : _apiClient = apiClient,
        _dbHelper = dbHelper;

  SummaryState get state => _state;
  VideoSummary? get currentSummary => _currentSummary;
  String? get errorMessage => _errorMessage;
  double get progress => _progress;

  Future<void> summarizeVideo(String url) async {
    _state = SummaryState.loading;
    _progress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Fetch transcript (0-50%)
      _progress = 0.2;
      notifyListeners();

      final transcript = await _apiClient.fetchTranscript(url);
      _progress = 0.5;
      notifyListeners();

      // Step 2: Summarize (50-100%)
      _progress = 0.65;
      notifyListeners();

      final summaryResponse = await _apiClient.summarize(
        videoId: transcript.videoId,
        title: transcript.title,
        transcriptText: transcript.transcriptText,
      );
      _progress = 0.9;
      notifyListeners();

      // Step 3: Build and cache result
      final videoSummary = VideoSummary(
        videoId: transcript.videoId,
        title: transcript.title,
        thumbnailUrl: transcript.thumbnailUrl,
        durationSeconds: transcript.durationSeconds,
        summary: summaryResponse.summary,
        keyPoints: summaryResponse.keyPoints,
        sections: summaryResponse.sections
            .map((s) => SummarySection(title: s.title, content: s.content))
            .toList(),
        transcriptText: transcript.transcriptText,
      );

      await _dbHelper.insertSummary(videoSummary);

      _currentSummary = videoSummary;
      _progress = 1.0;
      _state = SummaryState.success;
      notifyListeners();
    } catch (e) {
      _state = SummaryState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = SummaryState.idle;
    _currentSummary = null;
    _errorMessage = null;
    _progress = 0.0;
    notifyListeners();
  }
}
