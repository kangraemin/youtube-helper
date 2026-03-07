import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:youtube_helper/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('history');
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  runApp(
    const ProviderScope(
      child: YouTubeHelperApp(),
    ),
  );
}
