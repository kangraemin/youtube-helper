import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:youtube_helper/features/summarize/presentation/home_screen.dart';
import 'package:youtube_helper/features/summarize/presentation/summary_detail_screen.dart';
import 'package:youtube_helper/routing/shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Scaffold(
                appBar: AppBar(title: const Text('히스토리')),
                body: const Center(child: Text('히스토리')),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Scaffold(
                appBar: AppBar(title: const Text('설정')),
                body: const Center(child: Text('설정')),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/summary/:videoId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final videoId = state.pathParameters['videoId']!;
          return SummaryDetailScreen(videoId: videoId);
        },
      ),
    ],
  );
});
