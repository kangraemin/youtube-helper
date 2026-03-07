import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/features/summarize/application/settings_provider.dart';
import 'package:youtube_helper/features/summarize/application/history_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _serverUrlController;

  @override
  void initState() {
    super.initState();
    _serverUrlController =
        TextEditingController(text: ref.read(serverUrlProvider));
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '설정',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('다크 모드'),
            subtitle: const Text('어두운 테마를 사용합니다'),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: (_) {
              ref.read(isDarkModeProvider.notifier).toggle();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('서버 URL'),
            subtitle: Text(
              _serverUrlController.text,
              style: theme.textTheme.bodySmall,
            ),
            onTap: () => _showServerUrlDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              '히스토리 삭제',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('모든 요약 기록을 삭제합니다'),
            onTap: () => _showClearHistoryDialog(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('앱 버전'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showServerUrlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서버 URL'),
        content: TextField(
          controller: _serverUrlController,
          decoration: const InputDecoration(
            hintText: 'http://example.com:8000',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(serverUrlProvider.notifier)
                  .update(_serverUrlController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('히스토리 삭제'),
        content: const Text('모든 요약 기록이 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('히스토리가 삭제되었습니다')),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
