import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:youtube_helper/features/history/presentation/history_screen.dart';
import 'package:youtube_helper/features/settings/presentation/settings_screen.dart';
import 'package:youtube_helper/features/summary/presentation/home_screen.dart';
import 'package:youtube_helper/features/summary/presentation/summary_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: HomeScreen.routePath,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: HomeScreen.routePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: HistoryScreen.routePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: SettingsScreen.routePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: SummaryDetailScreen.routePath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SummaryDetailScreen(summaryId: id);
        },
      ),
    ],
  );
});

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(HistoryScreen.routePath)) return 1;
    if (location.startsWith(SettingsScreen.routePath)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(HomeScreen.routePath);
              case 1:
                context.go(HistoryScreen.routePath);
              case 2:
                context.go(SettingsScreen.routePath);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: '히스토리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
