import 'package:flutter_test/flutter_test.dart';

import 'package:youtube_helper/main.dart';

void main() {
  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const YouTubeHelperApp());

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('히스토리'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });
}
