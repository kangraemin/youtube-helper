import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:youtube_helper/app.dart';
import 'package:youtube_helper/core/constants/hive_constants.dart';
import 'package:youtube_helper/features/summary/infrastructure/summary_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();

  runApp(
    const ProviderScope(
      child: YouTubeHelperApp(),
    ),
  );
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  _registerAdapters();

  try {
    await _openBoxes();
  } catch (_) {
    await Hive.deleteFromDisk();
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SummaryHiveModelAdapter());
  }
}

Future<void> _openBoxes() async {
  await Hive.openBox<SummaryHiveModel>(HiveConstants.summaryBox);
}
