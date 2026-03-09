import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/summary_provider.dart';
import 'providers/history_provider.dart';
import 'providers/chat_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SummaryProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const YouTubeHelperApp(),
    ),
  );
}
