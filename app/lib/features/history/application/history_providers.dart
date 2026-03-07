import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/features/history/application/history_notifier.dart';
import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';

final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, List<SummaryEntity>>(
  HistoryNotifier.new,
);
