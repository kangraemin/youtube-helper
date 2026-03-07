import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/features/summary/application/summary_providers.dart';
import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';
import 'package:youtube_helper/features/summary/domain/repositories/summary_repository.dart';

class HistoryNotifier extends AsyncNotifier<List<SummaryEntity>> {
  SummaryRepository get _repository => ref.read(summaryRepositoryProvider);

  @override
  FutureOr<List<SummaryEntity>> build() {
    return _repository.getAll();
  }

  Future<void> refresh() async {
    state = AsyncData(await _repository.getAll());
  }

  Future<void> deleteSummary(String id) async {
    await _repository.delete(id);
    state = AsyncData(await _repository.getAll());
  }

  Future<void> deleteAll() async {
    await _repository.deleteAll();
    state = const AsyncData([]);
  }
}
