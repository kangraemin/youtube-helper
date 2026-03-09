import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  ChatProvider(this._apiService);

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(String url, String message) async {
    _errorMessage = null;
    final historyBeforeSend = List<ChatMessage>.from(_messages);
    _messages.add(ChatMessage(role: 'user', content: message));
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _apiService.sendChat(url, message, historyBeforeSend);
      final reply = response['reply'] as String? ?? '';
      _messages.add(ChatMessage(role: 'assistant', content: reply));
    } catch (e) {
      _errorMessage = e.toString();
      _messages.removeLast();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    _errorMessage = null;
    notifyListeners();
  }
}
