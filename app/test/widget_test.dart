import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:youtube_helper/app.dart';
import 'package:youtube_helper/services/api_service.dart';
import 'package:youtube_helper/providers/summary_provider.dart';
import 'package:youtube_helper/providers/history_provider.dart';
import 'package:youtube_helper/providers/chat_provider.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final apiService = ApiService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: apiService),
          ChangeNotifierProvider(create: (_) => SummaryProvider(apiService)),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider(apiService)),
        ],
        child: const App(),
      ),
    );
    expect(find.text('YouTube Helper'), findsOneWidget);
  });
}
