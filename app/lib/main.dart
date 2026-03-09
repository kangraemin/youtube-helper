import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/history_item.dart';
import 'services/api_service.dart';
import 'providers/summary_provider.dart';
import 'providers/history_provider.dart';
import 'providers/chat_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HistoryItemAdapter());

  final apiService = ApiService();
  final historyProvider = HistoryProvider();
  await historyProvider.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => SummaryProvider(apiService),
        ),
        ChangeNotifierProvider<HistoryProvider>.value(
          value: historyProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiService),
        ),
      ],
      child: const App(),
    ),
  );
}
