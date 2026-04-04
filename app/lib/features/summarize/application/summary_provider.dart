import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';
import 'package:youtube_helper/features/summarize/infrastructure/transcript_service.dart';
import 'package:youtube_helper/features/summarize/infrastructure/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final transcriptServiceProvider = Provider<TranscriptService>((ref) {
  return TranscriptService();
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

  const SummaryState({
    this.isLoading = false,
    this.progress = 0,
    this.error,
    this.result,
  });

  SummaryState copyWith({
    bool? isLoading,
    double? progress,
    String? error,
    VideoSummary? result,
  }) {
    return SummaryState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      error: error,
      result: result ?? this.result,
    );
  }
}

class SummaryNotifier extends StateNotifier<SummaryState> {
  final Ref _ref;

  SummaryNotifier(this._ref) : super(const SummaryState());

  Future<void> fetchTranscript(String url) async {
    state = const SummaryState(isLoading: true, progress: 0.1);
    try {
      final svc = _ref.read(transcriptServiceProvider);
      final storage = _ref.read(storageServiceProvider);

      final videoId = svc.extractVideoId(url);
      state = state.copyWith(progress: 0.3);

      final title = await svc.fetchVideoTitle(videoId);
      state = state.copyWith(progress: 0.5);

      final (segments, fullText) = await svc.fetchTranscript(videoId);
      state = state.copyWith(progress: 0.9);

      final videoSummary = VideoSummary(
        videoId: videoId,
        title: title,
        thumbnailUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
        fullText: fullText,
        summary: '',
        transcriptSegments: segments,
        createdAt: DateTime.now(),
      );

      await storage.save(videoSummary);

      state = SummaryState(result: videoSummary, progress: 1.0);
    } catch (e) {
      state = SummaryState(error: e.toString());
    }
  }

  void loadFromHistory(VideoSummary summary) {
    state = SummaryState(result: summary);
  }

  void clear() {
    state = const SummaryState();
  }
}
