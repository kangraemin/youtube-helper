import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/summary_provider.dart';
import '../../providers/history_provider.dart';
import '../detail/detail_screen.dart';

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

  Future<void> _pasteUrl() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  Future<void> _summarize() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final provider = context.read<SummaryProvider>();
    await provider.summarize(url);

    if (provider.state == SummaryState.success && mounted) {
      final summary = provider.currentSummary;
      if (summary != null) {
        await context.read<HistoryProvider>().addFromSummary(summary);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Helper'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUrlInput(),
            const SizedBox(height: 16),
            _buildSummarizeButton(),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInput() {
    return TextField(
      controller: _urlController,
      decoration: InputDecoration(
        hintText: 'YouTube 링크를 붙여넣으세요',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.paste),
          onPressed: _pasteUrl,
        ),
      ),
    );
  }

  Widget _buildSummarizeButton() {
    return Consumer<SummaryProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.state == SummaryState.loadingTranscript ||
            provider.state == SummaryState.loadingSummary;

        return SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _summarize,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('AI 요약 중...'),
                    ],
                  )
                : const Text(
                    '✨ 요약하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<SummaryProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case SummaryState.idle:
            return const SizedBox.shrink();
          case SummaryState.loadingTranscript:
            return _buildLoadingCard('자막을 가져오는 중...', 0.3);
          case SummaryState.loadingSummary:
            return _buildLoadingCard('AI 요약 중...', 0.65);
          case SummaryState.error:
            return _buildErrorCard(provider.errorMessage ?? '오류가 발생했습니다');
          case SummaryState.success:
            return _buildResultCard(provider);
        }
      },
    );
  }

  Widget _buildLoadingCard(String message, double progress) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFFFF4444),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toInt()}%',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(SummaryProvider provider) {
    final summary = provider.currentSummary!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: summary.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[300]),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  summary.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Summary quote
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: const Border(
                      left: BorderSide(color: Color(0xFFFF4444), width: 3),
                    ),
                    color: Colors.grey[50],
                  ),
                  child: Text(
                    summary.summary,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(summary: summary),
                            ),
                          );
                        },
                        icon: const Icon(Icons.article_outlined),
                        label: const Text('전문 보기'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: summary.summary));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('요약이 복사되었습니다')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('복사'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
