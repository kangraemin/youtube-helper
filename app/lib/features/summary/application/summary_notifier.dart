import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:youtube_helper/core/constants/api_constants.dart';
import 'package:youtube_helper/core/utils/url_validator.dart';
import 'package:youtube_helper/features/summary/application/summary_providers.dart';
import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';
import 'package:youtube_helper/features/summary/infrastructure/summary_api_service.dart';

const _uuid = Uuid();

enum ProcessingStep { idle, extracting, summarizing, done, error }

class ProcessingState {
  final ProcessingStep step;
  final double progress;
  final String? errorMessage;
  final SummaryEntity? result;

  const ProcessingState({
    this.step = ProcessingStep.idle,
    this.progress = 0,
    this.errorMessage,
    this.result,
  });

  ProcessingState copyWith({
    ProcessingStep? step,
    double? progress,
    String? errorMessage,
    SummaryEntity? result,
  }) {
    return ProcessingState(
      step: step ?? this.step,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }

  String get statusText {
    switch (step) {
      case ProcessingStep.idle:
        return '';
      case ProcessingStep.extracting:
        return '스크립트 추출 중...';
      case ProcessingStep.summarizing:
        return 'AI 요약 중...';
      case ProcessingStep.done:
        return '완료!';
      case ProcessingStep.error:
        return errorMessage ?? '오류가 발생했습니다';
    }
  }
}

class SummaryNotifier extends StateNotifier<ProcessingState> {
  final Ref _ref;

  SummaryNotifier(this._ref) : super(const ProcessingState());

  SummaryApiService get _apiService =>
      _ref.read(summaryApiServiceProvider);

  Future<void> processUrl(String url) async {
    final videoId = UrlValidator.extractVideoId(url);
    if (videoId == null) {
      state = const ProcessingState(
        step: ProcessingStep.error,
        errorMessage: '유효한 YouTube URL을 입력해주세요',
      );
      return;
    }

    try {
      // Step 1: Extract transcript
      state = const ProcessingState(
        step: ProcessingStep.extracting,
        progress: 0.3,
      );

      final transcriptResponse = await _apiService.fetchTranscript(url);

      state = state.copyWith(progress: 0.5);

      // Step 2: Summarize
      state = const ProcessingState(
        step: ProcessingStep.summarizing,
        progress: 0.65,
      );

      final summarizeResponse =
          await _apiService.summarize(transcriptResponse.transcript);

      state = state.copyWith(progress: 0.9);

      // Step 3: Create entity and save
      final entity = SummaryEntity(
        id: _uuid.v4(),
        videoId: transcriptResponse.videoId,
        videoTitle: transcriptResponse.videoTitle,
        thumbnailUrl: ApiConstants.thumbnailUrl(transcriptResponse.videoId),
        transcript: transcriptResponse.transcript,
        summary: summarizeResponse.summary,
        createdAt: DateTime.now(),
        videoUrl: url,
      );

      await _ref.read(summaryRepositoryProvider).add(entity);

      state = ProcessingState(
        step: ProcessingStep.done,
        progress: 1.0,
        result: entity,
      );
    } on ApiException catch (e) {
      state = ProcessingState(
        step: ProcessingStep.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = ProcessingState(
        step: ProcessingStep.error,
        errorMessage: '네트워크 오류가 발생했습니다. 서버 연결을 확인해주세요.',
      );
    }
  }

  void reset() {
    state = const ProcessingState();
  }
}

final summaryNotifierProvider =
    StateNotifierProvider<SummaryNotifier, ProcessingState>((ref) {
  return SummaryNotifier(ref);
});
