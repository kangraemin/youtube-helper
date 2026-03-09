import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('should create a ChatMessage with all fields', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final message = ChatMessage(
        role: 'user',
        content: 'Hello, world!',
        timestamp: timestamp,
      );
      expect(message.role, 'user');
      expect(message.content, 'Hello, world!');
      expect(message.timestamp, timestamp);
    });

    test('user factory should create user message', () {
      final message = ChatMessage.user('What is this video about?');
      expect(message.role, 'user');
      expect(message.content, 'What is this video about?');
      expect(message.isUser, true);
      expect(message.isAssistant, false);
    });

    test('assistant factory should create assistant message', () {
      final message = ChatMessage.assistant('This video is about Flutter.');
      expect(message.role, 'assistant');
      expect(message.content, 'This video is about Flutter.');
      expect(message.isUser, false);
      expect(message.isAssistant, true);
    });

    test('toJson should convert to valid JSON map', () {
      final message = ChatMessage(
        role: 'user',
        content: 'Test message',
        timestamp: DateTime(2024, 1, 15),
      );
      final json = message.toJson();
      expect(json['role'], 'user');
      expect(json['content'], 'Test message');
    });

    test('fromJson should create ChatMessage from JSON', () {
      final json = {
        'role': 'assistant',
        'content': 'Response text',
        'timestamp': '2024-01-15T10:30:00.000',
      };
      final message = ChatMessage.fromJson(json);
      expect(message.role, 'assistant');
      expect(message.content, 'Response text');
      expect(message.isAssistant, true);
    });

    test('fromJson should handle missing timestamp', () {
      final json = {
        'role': 'user',
        'content': 'No timestamp',
      };
      final message = ChatMessage.fromJson(json);
      expect(message.role, 'user');
      expect(message.content, 'No timestamp');
      expect(message.timestamp, isNotNull);
    });

    test('isUser and isAssistant should be mutually exclusive', () {
      final userMsg = ChatMessage.user('test');
      final assistantMsg = ChatMessage.assistant('test');
      expect(userMsg.isUser, true);
      expect(userMsg.isAssistant, false);
      expect(assistantMsg.isUser, false);
      expect(assistantMsg.isAssistant, true);
    });
  });
}
