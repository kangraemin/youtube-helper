import 'package:flutter/foundation.dart';
import '../data/api/api_client.dart';
import '../data/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _videoId;
  String? _transcriptText;

  ChatProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void initChat({
    required String videoId,
    required String transcriptText,
  }) {
    _videoId = videoId;
    _transcriptText = transcriptText;
    _messages = [];
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_videoId == null || _transcriptText == null) return;

    final userMessage = ChatMessage(role: 'user', content: content);
    _messages = [..._messages, userMessage];
    _isLoading = true;
    notifyListeners();

    try {
      final reply = await _apiClient.chat(
        videoId: _videoId!,
        transcriptText: _transcriptText!,
        messages: _messages,
      );

      final assistantMessage = ChatMessage(role: 'assistant', content: reply);
      _messages = [..._messages, assistantMessage];
    } catch (e) {
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: '오류가 발생했습니다. 다시 시도해주세요.',
      );
      _messages = [..._messages, errorMessage];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages = [];
    _videoId = null;
    _transcriptText = null;
    notifyListeners();
  }
}
