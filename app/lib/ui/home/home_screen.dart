import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/summary_provider.dart';
import '../detail/detail_screen.dart';
import 'widgets/url_input_field.dart';
import 'widgets/summary_button.dart';
import 'widgets/progress_indicator_widget.dart';
import 'widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onSummarize() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    context.read<SummaryProvider>().summarizeVideo(url);
  }

  void _navigateToDetail(String videoId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<SummaryProvider>(),
          child: DetailScreen(videoId: videoId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_filled, color: AppTheme.primaryRed, size: 28),
            const SizedBox(width: 8),
            const Text(
              'YouTube Helper',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Consumer<SummaryProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UrlInputField(
                  controller: _urlController,
                  enabled: provider.state != SummaryState.loading,
                ),
                const SizedBox(height: 16),
                SummaryButton(
                  onPressed: _onSummarize,
                  isLoading: provider.state == SummaryState.loading,
                ),
                if (provider.state == SummaryState.loading) ...[
                  const SizedBox(height: 24),
                  ProgressIndicatorWidget(progress: provider.progress),
                ],
                if (provider.state == SummaryState.error) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage ?? '오류가 발생했습니다',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (provider.currentSummary != null) ...[
                  const SizedBox(height: 24),
                  VideoCard(
                    summary: provider.currentSummary!,
                    onTap: () {
                      _navigateToDetail(provider.currentSummary!.videoId);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
