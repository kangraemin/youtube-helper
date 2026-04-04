import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/features/summarize/application/summary_provider.dart';
import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';

class SummaryDetailScreen extends ConsumerWidget {
  final String videoId;

  const SummaryDetailScreen({super.key, required this.videoId});

  String _formatTime(double seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds.toInt() % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(summaryNotifierProvider);
    final summary = summaryState.result;
    final theme = Theme.of(context);

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('스크립트 데이터를 찾을 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          summary.title,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: summary.fullText));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('스크립트가 복사되었습니다')),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.content_copy, color: Colors.white),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              summary.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
          ),
          Expanded(
            child: _buildTranscriptList(summary, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptList(VideoSummary summary, ThemeData theme) {
    if (summary.transcriptSegments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '스크립트가 없습니다',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: summary.transcriptSegments.length,
      itemBuilder: (context, index) {
        final segment = summary.transcriptSegments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  _formatTime(segment.start),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  segment.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
