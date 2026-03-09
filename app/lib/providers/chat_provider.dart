import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  ChatProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage({
    required String videoId,
    required String fullText,
    required String userMessage,
  }) async {
    _messages.add(ChatMessage(role: 'user', content: userMessage));
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reply = await _apiService.chat(
        videoId: videoId,
        fullText: fullText,
        messages: _messages,
      );

      _messages.add(ChatMessage(role: 'assistant', content: reply));
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
