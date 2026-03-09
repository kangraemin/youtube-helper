import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_helper/providers/history_provider.dart';
import 'package:youtube_helper/providers/summary_provider.dart';
import 'package:youtube_helper/screens/home_screen.dart';
import 'package:youtube_helper/services/api_service.dart';

Widget createTestApp({http.Client? client}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/history',
            builder: (context, state) => const Scaffold(),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      if (client != null)
        apiServiceProvider.overrideWithValue(ApiService(client: client)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('URL 입력 필드와 요약하기 버튼이 표시된다', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: createTestApp(),
        ),
      );

      expect(find.text('YouTube Helper'), findsOneWidget);
      expect(find.text('요약하기'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('URL 입력 후 요약하기 버튼을 누르면 로딩 표시', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final completer = Completer<http.Response>();
      final mockClient = MockClient((request) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            apiServiceProvider.overrideWithValue(
              ApiService(client: mockClient),
            ),
          ],
          child: createTestApp(client: mockClient),
        ),
      );

      await tester.enterText(
        find.byType(TextField),
        'https://youtube.com/watch?v=test',
      );
      await tester.tap(find.text('요약하기'));
      await tester.pump();

      expect(find.text('자막 추출 중...'), findsOneWidget);

      // Complete the future to clean up
      completer.complete(http.Response(
        jsonEncode({
          'video_id': 'test',
          'title': 'Test',
          'thumbnail_url': 'url',
          'duration': '1:00',
          'transcript': 'text',
        }),
        200,
      ));
      await tester.pumpAndSettle();
    });
  });
}
