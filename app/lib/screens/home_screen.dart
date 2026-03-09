import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/summary_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/video_card.dart';
import 'detail_screen.dart';

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

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  void _startSummarize() {
    final provider = context.read<SummaryProvider>();
    final historyProvider = context.read<HistoryProvider>();
    provider.processVideo(_urlController.text).then((_) {
      if (provider.state == SummaryState.done) {
        historyProvider.loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('YouTube Helper'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Switch to history tab via bottom nav
              final scaffold = context.findAncestorStateOfType<State>();
              if (scaffold != null) {
                // Navigate using bottom nav callback
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YouTube URL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'YouTube 링크를 붙여넣으세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  onPressed: _pasteFromClipboard,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Consumer<SummaryProvider>(
                builder: (context, provider, _) {
                  final isProcessing =
                      provider.state == SummaryState.fetchingTranscript ||
                          provider.state == SummaryState.summarizing;
                  return ElevatedButton.icon(
                    onPressed: isProcessing ? null : _startSummarize,
                    icon: const Text('✦', style: TextStyle(fontSize: 18)),
                    label: const Text(
                      '요약하기',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Consumer<SummaryProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    // Progress indicator
                    if (provider.state == SummaryState.fetchingTranscript ||
                        provider.state == SummaryState.summarizing)
                      _buildProgressCard(provider),

                    // Error message
                    if (provider.state == SummaryState.error)
                      _buildErrorCard(provider.errorMessage ?? '알 수 없는 오류'),

                    // Result
                    if (provider.state == SummaryState.done &&
                        provider.currentVideo != null)
                      _buildResultSection(provider),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(SummaryProvider provider) {
    final statusText = provider.state == SummaryState.fetchingTranscript
        ? '자막 가져오는 중...'
        : 'AI 요약 중...';
    final percent = (provider.progress * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  '$statusText $percent%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: provider.progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(SummaryProvider provider) {
    final video = provider.currentVideo!;
    return Column(
      children: [
        VideoCard(video: video),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(video: video),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('전문 보기'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (video.summary != null) {
                  Clipboard.setData(ClipboardData(text: video.summary!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('요약이 복사되었습니다.')),
                  );
                }
              },
              icon: const Icon(Icons.copy, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
