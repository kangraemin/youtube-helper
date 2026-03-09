import 'package:flutter/foundation.dart';
import '../models/video_summary.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

enum SummaryState { idle, loading, loaded, error }

class SummaryProvider extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  SummaryState _state = SummaryState.idle;
  VideoSummary? _currentSummary;
  String _errorMessage = '';
  double _progress = 0.0;
  String _progressText = '';
  List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;

  SummaryProvider({
    required ApiService apiService,
    required DatabaseService databaseService,
  })  : _apiService = apiService,
        _databaseService = databaseService;

  SummaryState get state => _state;
  VideoSummary? get currentSummary => _currentSummary;
  String get errorMessage => _errorMessage;
  double get progress => _progress;
  String get progressText => _progressText;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isChatLoading => _isChatLoading;

  Future<void> summarizeUrl(String url) async {
    _state = SummaryState.loading;
    _progress = 0.0;
    _progressText = '자막 가져오는 중...';
    _errorMessage = '';
    _chatMessages = [];
    notifyListeners();

    try {
      _progress = 0.3;
      _progressText = '자막 가져오는 중...';
      notifyListeners();

      final transcriptResponse = await _apiService.fetchTranscript(url);

      _progress = 0.6;
      _progressText = 'AI 요약 중...';
      notifyListeners();

      final summarizeResponse = await _apiService.summarize(
        transcriptResponse.videoId,
        transcriptResponse.transcript,
        transcriptResponse.title,
      );

      _progress = 0.9;
      _progressText = '저장 중...';
      notifyListeners();

      final summary = VideoSummary(
        videoId: transcriptResponse.videoId,
        title: transcriptResponse.title,
        thumbnailUrl: transcriptResponse.thumbnailUrl,
        duration: transcriptResponse.duration,
        transcript: transcriptResponse.transcript,
        summary: summarizeResponse.summary,
        keyPoints: summarizeResponse.keyPoints,
        transcriptPreview: summarizeResponse.transcriptPreview,
        language: transcriptResponse.language,
        createdAt: DateTime.now(),
      );

      await _databaseService.saveSummary(summary);

      _currentSummary = summary;
      _progress = 1.0;
      _progressText = '완료!';
      _state = SummaryState.loaded;
      notifyListeners();
    } catch (e) {
      _state = SummaryState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setCurrentSummary(VideoSummary summary) {
    _currentSummary = summary;
    _state = SummaryState.loaded;
    _chatMessages = [];
    notifyListeners();
  }

  Future<void> sendChatMessage(String question) async {
    if (_currentSummary == null) return;

    final userMessage = ChatMessage.user(question);
    _chatMessages = [..._chatMessages, userMessage];
    _isChatLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.chat(
        _currentSummary!.videoId,
        _currentSummary!.transcript,
        question,
        _chatMessages,
      );

      final assistantMessage = ChatMessage.assistant(response.answer);
      _chatMessages = [..._chatMessages, assistantMessage];
      _isChatLoading = false;
      notifyListeners();
    } catch (e) {
      _isChatLoading = false;
      final errorMessage = ChatMessage.assistant('오류가 발생했습니다: $e');
      _chatMessages = [..._chatMessages, errorMessage];
      notifyListeners();
    }
  }

  void reset() {
    _state = SummaryState.idle;
    _currentSummary = null;
    _errorMessage = '';
    _progress = 0.0;
    _progressText = '';
    _chatMessages = [];
    _isChatLoading = false;
    notifyListeners();
  }
}
