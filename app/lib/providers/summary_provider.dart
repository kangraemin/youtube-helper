import 'package:flutter/foundation.dart';
import '../models/video_summary.dart';
import '../services/api_service.dart';

enum SummaryState { idle, loadingTranscript, loadingSummary, success, error }

class SummaryProvider extends ChangeNotifier {
  final ApiService _apiService;

  SummaryState _state = SummaryState.idle;
  VideoSummary? _currentSummary;
  String? _errorMessage;
  String? _currentUrl;

  SummaryProvider(this._apiService);

  SummaryState get state => _state;
  VideoSummary? get currentSummary => _currentSummary;
  String? get errorMessage => _errorMessage;
  String? get currentUrl => _currentUrl;

  Future<void> summarize(String url) async {
    _currentUrl = url;
    _errorMessage = null;

    try {
      _state = SummaryState.loadingTranscript;
      notifyListeners();

      final transcriptData = await _apiService.fetchTranscript(url);
      final fullText = transcriptData['full_text'] as String?;
      final segmentsJson = transcriptData['segments'] as List<dynamic>?;
      final segments = segmentsJson
          ?.map((s) =>
              TranscriptSegment.fromJson(s as Map<String, dynamic>))
          .toList();

      _state = SummaryState.loadingSummary;
      notifyListeners();

      final summary = await _apiService.fetchSummary(url);
      _currentSummary = VideoSummary(
        videoId: summary.videoId,
        title: summary.title,
        thumbnailUrl: summary.thumbnailUrl,
        summary: summary.summary,
        keyPoints: summary.keyPoints,
        tips: summary.tips,
        fullText: fullText,
        segments: segments,
      );

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
    _currentUrl = null;
    notifyListeners();
  }
}
