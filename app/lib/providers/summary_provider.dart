import 'package:flutter/foundation.dart';
import '../models/video_summary.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum SummaryStatus { idle, loading, success, error }

class SummaryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  SummaryStatus _status = SummaryStatus.idle;
  VideoSummary? _currentSummary;
  String _errorMessage = '';
  int _progress = 0;
  List<VideoSummary> _history = [];

  // Chat state
  final List<Map<String, String>> _chatMessages = [];
  bool _isChatLoading = false;

  SummaryStatus get status => _status;
  VideoSummary? get currentSummary => _currentSummary;
  String get errorMessage => _errorMessage;
  int get progress => _progress;
  List<VideoSummary> get history => _history;
  List<Map<String, String>> get chatMessages => _chatMessages;
  bool get isChatLoading => _isChatLoading;

  Future<void> summarizeVideo(String url) async {
    _status = SummaryStatus.loading;
    _progress = 0;
    _errorMessage = '';
    _chatMessages.clear();
    notifyListeners();

    try {
      // Step 1: Get transcript (0-50%)
      _progress = 20;
      notifyListeners();

      final transcriptData = await _apiService.getTranscript(url);
      _progress = 50;
      notifyListeners();

      final videoId = transcriptData['video_id'] as String? ?? '';
      final title = transcriptData['title'] as String? ?? '';
      final thumbnailUrl = transcriptData['thumbnail_url'] as String? ??
          'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      final transcript = transcriptData['transcript'] as String? ?? '';

      // Step 2: Summarize (50-100%)
      _progress = 70;
      notifyListeners();

      final summaryData = await _apiService.summarize(transcript);
      _progress = 100;
      notifyListeners();

      final summary = VideoSummary(
        videoId: videoId,
        title: title,
        thumbnailUrl: thumbnailUrl,
        transcript: transcript,
        summary: summaryData['summary'] as String? ?? '',
        keyPoints: (summaryData['key_points'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

      _currentSummary = summary;
      _status = SummaryStatus.success;

      // Save to history
      await _storageService.saveSummary(summary);
      await loadHistory();
    } catch (e) {
      _status = SummaryStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _history = await _storageService.getHistory();
    notifyListeners();
  }

  void selectSummary(VideoSummary summary) {
    _currentSummary = summary;
    _chatMessages.clear();
    notifyListeners();
  }

  Future<void> sendChatMessage(String question) async {
    if (_currentSummary == null) return;

    _chatMessages.add({'role': 'user', 'content': question});
    _isChatLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.chat(
        transcript: _currentSummary!.transcript,
        question: question,
        messages: _chatMessages,
      );

      final answer = response['answer'] as String? ?? '';
      _chatMessages.add({'role': 'assistant', 'content': answer});
    } catch (e) {
      _chatMessages.add({
        'role': 'assistant',
        'content': '오류가 발생했습니다: $e',
      });
    }

    _isChatLoading = false;
    notifyListeners();
  }

  void reset() {
    _status = SummaryStatus.idle;
    _currentSummary = null;
    _errorMessage = '';
    _progress = 0;
    _chatMessages.clear();
    notifyListeners();
  }
}
