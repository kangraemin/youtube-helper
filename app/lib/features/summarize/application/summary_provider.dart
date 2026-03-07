import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:youtube_helper/core/constants/api_constants.dart';
import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';
import 'package:youtube_helper/features/summarize/domain/entities/chat_message.dart';
import 'package:youtube_helper/features/summarize/infrastructure/api_service.dart';
import 'package:youtube_helper/features/summarize/infrastructure/storage_service.dart';
import 'package:youtube_helper/features/summarize/application/settings_provider.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  return ApiService(baseUrl: serverUrl);
});

final summaryNotifierProvider =
    StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  return SummaryNotifier(ref);
});

class SummaryState {
  final bool isLoading;
  final double progress;
  final String? error;
  final VideoSummary? result;
  final List<ChatMessage> chatMessages;

  const SummaryState({
    this.isLoading = false,
    this.progress = 0,
    this.error,
    this.result,
    this.chatMessages = const [],
  });

  SummaryState copyWith({
    bool? isLoading,
    double? progress,
    String? error,
    VideoSummary? result,
    List<ChatMessage>? chatMessages,
  }) {
    return SummaryState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      error: error,
      result: result ?? this.result,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }
}

class SummaryNotifier extends StateNotifier<SummaryState> {
  final Ref _ref;

  SummaryNotifier(this._ref) : super(const SummaryState());

  Future<void> summarize(String url) async {
    state = const SummaryState(isLoading: true, progress: 0.1);
    try {
      final api = _ref.read(apiServiceProvider);
      final storage = _ref.read(storageServiceProvider);

      state = state.copyWith(progress: 0.3);
      final transcriptData = await api.fetchTranscript(url);

      final videoId = transcriptData['video_id'] as String;
      final title = transcriptData['title'] as String;
      final fullText = transcriptData['full_text'] as String;
      final segments = (transcriptData['transcript'] as List)
          .map((s) => TranscriptSegment(
                text: s['text'] as String,
                start: (s['start'] as num).toDouble(),
                duration: (s['duration'] as num).toDouble(),
              ))
          .toList();

      state = state.copyWith(progress: 0.6);
      final summary = await api.fetchSummary(
        videoId: videoId,
        title: title,
        fullText: fullText,
      );

      state = state.copyWith(progress: 0.9);
      final videoSummary = VideoSummary(
        videoId: videoId,
        title: title,
        thumbnailUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
        fullText: fullText,
        summary: summary,
        transcriptSegments: segments,
        createdAt: DateTime.now(),
      );

      await storage.save(videoSummary);

      state = SummaryState(
        result: videoSummary,
        progress: 1.0,
      );
    } catch (e) {
      state = SummaryState(error: e.toString());
    }
  }

  Future<void> sendChat(String message) async {
    if (state.result == null) return;

    final newMessages = [
      ...state.chatMessages,
      ChatMessage(role: 'user', content: message),
    ];
    state = state.copyWith(chatMessages: newMessages, isLoading: true);

    try {
      final api = _ref.read(apiServiceProvider);
      final reply = await api.sendChat(
        videoId: state.result!.videoId,
        title: state.result!.title,
        fullText: state.result!.fullText,
        messages: newMessages,
      );

      state = state.copyWith(
        chatMessages: [
          ...newMessages,
          ChatMessage(role: 'assistant', content: reply),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void loadFromHistory(VideoSummary summary) {
    state = SummaryState(result: summary);
  }

  void clear() {
    state = const SummaryState();
  }
}
