import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/core/constants/api_constants.dart';
import 'package:youtube_helper/features/summary/application/summary_providers.dart';

final darkModeProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const routePath = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _serverUrlController;

  @override
  void initState() {
    super.initState();
    _serverUrlController = TextEditingController(
      text: ref.read(serverUrlProvider),
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(darkModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Server URL
          Text(
            '서버 설정',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '서버 URL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _serverUrlController,
                  decoration: const InputDecoration(
                    hintText: 'http://example.com:8000',
                  ),
                  onChanged: (value) {
                    ref.read(serverUrlProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _serverUrlController.text = ApiConstants.defaultBaseUrl;
                    ref.read(serverUrlProvider.notifier).state =
                        ApiConstants.defaultBaseUrl;
                  },
                  child: Text(
                    '기본값으로 초기화',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dark Mode
          Text(
            '테마',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: SwitchListTile(
              title: const Text(
                '다크 모드',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isDarkMode ? '어두운 테마 사용 중' : '밝은 테마 사용 중',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              value: isDarkMode,
              activeTrackColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                ref.read(darkModeProvider.notifier).state = value;
              },
            ),
          ),

          const SizedBox(height: 32),

          // App info
          Center(
            child: Text(
              'YouTube Helper v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
