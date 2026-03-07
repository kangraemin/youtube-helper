import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/core/theme/app_theme.dart';
import 'package:youtube_helper/features/summarize/application/settings_provider.dart';
import 'package:youtube_helper/routing/app_router.dart';

class YouTubeHelperApp extends ConsumerWidget {
  const YouTubeHelperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp.router(
      title: 'YouTube Helper',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
