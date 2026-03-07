import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';
import 'package:youtube_helper/features/summarize/infrastructure/storage_service.dart';
import 'package:youtube_helper/features/summarize/application/summary_provider.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<VideoSummary>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HistoryNotifier(storage);
});

class HistoryNotifier extends StateNotifier<List<VideoSummary>> {
  final StorageService _storage;

  HistoryNotifier(this._storage) : super([]) {
    refresh();
  }

  void refresh() {
    state = _storage.getAll();
  }

  Future<void> delete(String videoId) async {
    await _storage.delete(videoId);
    refresh();
  }

  Future<void> clearAll() async {
    await _storage.clearAll();
    refresh();
  }
}
