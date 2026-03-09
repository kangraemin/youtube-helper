import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/api/api_client.dart';
import 'data/local/database_helper.dart';
import 'providers/summary_provider.dart';
import 'providers/history_provider.dart';
import 'providers/chat_provider.dart';
import 'ui/home/home_screen.dart';
import 'ui/history/history_screen.dart';
import 'ui/settings/settings_screen.dart';

class App extends StatefulWidget {
  final ApiClient? apiClient;
  final DatabaseHelper? dbHelper;

  const App({super.key, this.apiClient, this.dbHelper});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ApiClient _apiClient;
  late final DatabaseHelper _dbHelper;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _dbHelper = widget.dbHelper ?? DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SummaryProvider(
            apiClient: _apiClient,
            dbHelper: _dbHelper,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(dbHelper: _dbHelper),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiClient: _apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'YouTube Helper',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: _ShellScreen(
          selectedIndex: _selectedIndex,
          onIndexChanged: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}

class _ShellScreen extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _ShellScreen({
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomeScreen(),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onIndexChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '히스토리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
