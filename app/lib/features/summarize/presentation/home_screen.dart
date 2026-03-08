import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:youtube_helper/features/summarize/application/summary_provider.dart';
import 'package:youtube_helper/features/summarize/presentation/widgets/loading_progress.dart';
import 'package:youtube_helper/features/summarize/presentation/widgets/video_result_card.dart';

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
    ref.read(summaryNotifierProvider.notifier).summarize(url);
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(summaryNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_display, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'YouTube Helper',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YouTube URL',
              style: theme.textTheme.labelLarge?.copyWith(
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  onPressed: _pasteFromClipboard,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: summaryState.isLoading ? null : _summarize,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  '요약하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (summaryState.isLoading) ...[
              const SizedBox(height: 24),
              LoadingProgress(progress: summaryState.progress),
            ],
            if (summaryState.error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summaryState.error!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                      if (summaryState.result != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: summaryState.result!.fullText,
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('스크립트가 클립보드에 복사됐어요')),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('스크립트 복사'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  context.push('/summary/${summaryState.result!.videoId}');
                                },
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('상세보기'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (summaryState.result != null) ...[
              const SizedBox(height: 24),
              VideoResultCard(
                summary: summaryState.result!,
                onViewDetail: () {
                  context.push('/summary/${summaryState.result!.videoId}');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
