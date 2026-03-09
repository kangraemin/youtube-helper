import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/video_summary.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(client: http.Client());
});

enum SummaryStatus { idle, loadingTranscript, loadingSummary, done, error }

class SummaryState {
  final SummaryStatus status;
  final VideoTranscript? transcript;
  final VideoSummary? summary;
  final String? errorMessage;
  final double progress;

  const SummaryState({
    this.status = SummaryStatus.idle,
    this.transcript,
    this.summary,
    this.errorMessage,
    this.progress = 0.0,
  });

  SummaryState copyWith({
    SummaryStatus? status,
    VideoTranscript? transcript,
    VideoSummary? summary,
    String? errorMessage,
    double? progress,
  }) {
    return SummaryState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }
}

class SummaryNotifier extends Notifier<SummaryState> {
  @override
  SummaryState build() => const SummaryState();

  ApiService get _apiService => ref.read(apiServiceProvider);

  Future<void> summarize(String url) async {
    state = const SummaryState(
      status: SummaryStatus.loadingTranscript,
      progress: 0.3,
    );

    try {
      final transcript = await _apiService.fetchTranscript(url);
      state = state.copyWith(
        status: SummaryStatus.loadingSummary,
        transcript: transcript,
        progress: 0.6,
      );

      final summary = await _apiService.summarize(
        transcript.videoId,
        transcript.transcript,
      );
      state = state.copyWith(
        status: SummaryStatus.done,
        summary: summary,
        progress: 1.0,
      );
    } catch (e) {
      state = SummaryState(
        status: SummaryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const SummaryState();
  }
}

final summaryProvider =
    NotifierProvider<SummaryNotifier, SummaryState>(SummaryNotifier.new);
