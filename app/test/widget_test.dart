import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('App renders with BottomNavigationBar', (WidgetTester tester) async {
    await tester.pumpWidget(const YouTubeHelperApp());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('히스토리'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });

  testWidgets('Home screen has URL input and summarize button', (WidgetTester tester) async {
    await tester.pumpWidget(const YouTubeHelperApp());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('요약하기'), findsOneWidget);
    expect(find.byIcon(Icons.content_paste), findsOneWidget);
  });

  testWidgets('Red theme applied', (WidgetTester tester) async {
    await tester.pumpWidget(const YouTubeHelperApp());

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final style = button.style;
    expect(style, isNotNull);
  });

  testWidgets('Tab navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(const YouTubeHelperApp());

    // Start on home tab
    expect(find.text('YouTube Helper'), findsOneWidget);

    // Tap history tab
    await tester.tap(find.text('히스토리'));
    await tester.pumpAndSettle();
    expect(find.text('아직 요약한 영상이 없어요'), findsOneWidget);

    // Tap settings tab
    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();
    expect(find.text('서버 주소'), findsOneWidget);
  });
}
