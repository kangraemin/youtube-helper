import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_summary.dart';
import '../services/storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(prefs: ref.read(sharedPreferencesProvider));
});

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  @override
  List<HistoryEntry> build() {
    return ref.read(storageServiceProvider).getHistoryEntries();
  }

  Future<void> addEntry(HistoryEntry entry) async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveHistoryEntry(entry);
    state = storage.getHistoryEntries();
  }

  Future<void> clearAll() async {
    await ref.read(storageServiceProvider).clearHistory();
    state = [];
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<HistoryEntry>>(HistoryNotifier.new);
