import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_helper/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const YouTubeHelperApp());
    expect(find.text('YouTube Helper'), findsOneWidget);
  });
}
