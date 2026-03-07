import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:youtube_helper/core/utils/url_validator.dart';
import 'package:youtube_helper/features/summary/application/summary_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routePath = '/';

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

  void _onSubmit() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    if (!UrlValidator.isValidYoutubeUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 YouTube URL을 입력해주세요')),
      );
      return;
    }

    ref.read(summaryNotifierProvider.notifier).processUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final processingState = ref.watch(summaryNotifierProvider);
    final theme = Theme.of(context);
    final isProcessing = processingState.step == ProcessingStep.extracting ||
        processingState.step == ProcessingStep.summarizing;

    ref.listen(summaryNotifierProvider, (prev, next) {
      if (next.step == ProcessingStep.done && next.result != null) {
        context.push('/summary/${next.result!.id}');
        ref.read(summaryNotifierProvider.notifier).reset();
        _urlController.clear();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_display, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            const Text(
              'YouTube Helper',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Input Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'YouTube URL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _urlController,
                      enabled: !isProcessing,
                      decoration: InputDecoration(
                        hintText: 'YouTube 링크를 붙여넣으세요',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.content_paste,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          onPressed: isProcessing ? null : _pasteFromClipboard,
                        ),
                      ),
                      onSubmitted: (_) => _onSubmit(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shadowColor:
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, size: 20),
                          const SizedBox(width: 8),
                          const Text('요약하기'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading State
            if (isProcessing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                processingState.statusText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(processingState.progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: processingState.progress,
                          backgroundColor:
                              theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          color: theme.colorScheme.primary,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error State
            if (processingState.step == ProcessingStep.error)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade400),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          processingState.errorMessage ?? '오류가 발생했습니다',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
