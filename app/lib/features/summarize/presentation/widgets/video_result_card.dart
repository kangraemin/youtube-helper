import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';

class VideoResultCard extends StatelessWidget {
  final VideoSummary summary;
  final VoidCallback? onViewDetail;

  const VideoResultCard({
    super.key,
    required this.summary,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    summary.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: onViewDetail,
                        icon: const Icon(Icons.description, size: 18),
                        label: const Text('전문 보기'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: summary.fullText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('스크립트가 복사되었습니다')),
                        );
                      },
                      icon: const Icon(Icons.subtitles, size: 18),
                      tooltip: '스크립트 복사',
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
