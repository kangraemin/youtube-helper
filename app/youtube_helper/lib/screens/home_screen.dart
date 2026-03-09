import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/summary_provider.dart';
import '../providers/history_provider.dart';
import '../models/video_summary.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  void _summarize() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    ref.read(summaryProvider.notifier).summarize(url);
  }

  void _saveToHistory(SummaryState state) {
    if (state.transcript != null && state.summary != null) {
      final entry = HistoryEntry(
        videoId: state.transcript!.videoId,
        title: state.transcript!.title,
        thumbnailUrl: state.transcript!.thumbnailUrl,
        duration: state.transcript!.duration,
        summaryPreview: state.summary!.summary.length > 100
            ? '${state.summary!.summary.substring(0, 100)}...'
            : state.summary!.summary,
        transcript: state.transcript!.transcript,
        summary: state.summary!.summary,
        keyPoints: state.summary!.keyPoints,
        actionPoints: state.summary!.actionPoints,
        createdAt: DateTime.now(),
      );
      ref.read(historyProvider.notifier).addEntry(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(summaryProvider);

    ref.listen<SummaryState>(summaryProvider, (prev, next) {
      if (next.status == SummaryStatus.done) {
        _saveToHistory(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('YouTube Helper',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('YouTube URL',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
            ElevatedButton.icon(
              onPressed: state.status == SummaryStatus.loadingTranscript ||
                      state.status == SummaryStatus.loadingSummary
                  ? null
                  : _summarize,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('요약하기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (state.status == SummaryStatus.loadingTranscript ||
                state.status == SummaryStatus.loadingSummary) ...[
              const SizedBox(height: 24),
              _buildLoadingSection(state),
            ],
            if (state.status == SummaryStatus.error) ...[
              const SizedBox(height: 24),
              _buildErrorSection(state),
            ],
            if (state.status == SummaryStatus.done) ...[
              const SizedBox(height: 24),
              _buildResultSection(state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection(SummaryState state) {
    final label = state.status == SummaryStatus.loadingTranscript
        ? '자막 추출 중...'
        : 'AI 요약 중...';
    final percent = (state.progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt, color: Colors.red.shade400, size: 18),
                  const SizedBox(width: 4),
                  Text(label,
                      style: TextStyle(color: Colors.red.shade700)),
                ],
              ),
              Text('$percent%',
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.red.shade100,
            valueColor: AlwaysStoppedAnimation(Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(SummaryState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        state.errorMessage ?? '오류가 발생했습니다',
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }

  Widget _buildResultSection(SummaryState state) {
    final transcript = state.transcript!;
    final summary = state.summary!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: transcript.thumbnailUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(height: 200, color: Colors.grey.shade200),
                errorWidget: (context, url, error) =>
                    Container(height: 200, color: Colors.grey.shade200,
                        child: const Icon(Icons.error)),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(transcript.duration,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(transcript.title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${summary.summary}"',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final entry = HistoryEntry(
                    videoId: transcript.videoId,
                    title: transcript.title,
                    thumbnailUrl: transcript.thumbnailUrl,
                    duration: transcript.duration,
                    summaryPreview: summary.summary.length > 100
                        ? '${summary.summary.substring(0, 100)}...'
                        : summary.summary,
                    transcript: transcript.transcript,
                    summary: summary.summary,
                    keyPoints: summary.keyPoints,
                    actionPoints: summary.actionPoints,
                    createdAt: DateTime.now(),
                  );
                  context.push('/detail', extra: entry);
                },
                icon: const Icon(Icons.article, size: 18),
                label: const Text('전문 보기'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: summary.summary));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('요약이 복사되었습니다')),
                );
              },
              icon: const Icon(Icons.copy, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}
