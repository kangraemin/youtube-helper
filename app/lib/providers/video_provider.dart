import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_summary.dart';
import '../services/api_service.dart';

class VideoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  VideoSummary? _currentVideo;
  List<VideoSummary> _history = [];
  bool _isLoading = false;
  double _progress = 0.0;
  String? _errorMessage;
  final List<Map<String, String>> _chatHistory = [];

  VideoSummary? get currentVideo => _currentVideo;
  List<VideoSummary> get history => _history;
  bool get isLoading => _isLoading;
  double get progress => _progress;
  String? get errorMessage => _errorMessage;

  VideoProvider() {
    loadHistory();
  }

  Future<void> processVideo(String url) async {
    _isLoading = true;
    _progress = 0.0;
    _errorMessage = null;
    _chatHistory.clear();
    notifyListeners();

    try {
      _progress = 0.3;
      notifyListeners();

      final video = await _apiService.fetchTranscript(url);
      _currentVideo = video;
      _progress = 0.6;
      notifyListeners();

      final result = await _apiService.summarize(
        video.videoId,
        video.transcript,
        video.title,
      );

      _currentVideo!.summary = result['summary'] as String?;
      _currentVideo!.keyPoints = (result['key_points'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

      _progress = 1.0;
      notifyListeners();

      _history.insert(0, _currentVideo!);
      await saveHistory();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> askQuestion(String question) async {
    if (_currentVideo == null) {
      throw Exception('영상을 먼저 로드해주세요');
    }

    final answer = await _apiService.chat(
      _currentVideo!.videoId,
      _currentVideo!.transcript,
      question,
      _chatHistory,
    );

    _chatHistory.add({'role': 'user', 'content': question});
    _chatHistory.add({'role': 'assistant', 'content': answer});

    return answer;
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('video_history');
    if (historyJson != null) {
      final List<dynamic> list = jsonDecode(historyJson) as List<dynamic>;
      _history = list
          .map((e) => VideoSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString('video_history', historyJson);
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('video_history');
    notifyListeners();
  }

  void selectVideo(VideoSummary video) {
    _currentVideo = video;
    _chatHistory.clear();
    notifyListeners();
  }
}
