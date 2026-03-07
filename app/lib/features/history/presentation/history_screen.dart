import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:youtube_helper/features/history/application/history_providers.dart';
import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const routePath = '/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '히스토리',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (summaries) {
          if (summaries.isEmpty) {
            return _buildEmptyState(theme);
          }
          return _buildList(context, ref, summaries, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 요약한 영상이 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '유튜브 영상 링크를 복사해와서\n첫 요약을 시작해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<SummaryEntity> summaries,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '최근 요약 기록',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return _HistoryListItem(
                summary: summary,
                onTap: () => context.push('/summary/${summary.id}'),
                onDelete: () {
                  ref
                      .read(historyNotifierProvider.notifier)
                      .deleteSummary(summary.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final SummaryEntity summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryListItem({
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 2) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return DateFormat('yyyy.MM.dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(summary.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: theme.colorScheme.primary,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 96,
                  height: 64,
                  child: Image.network(
                    summary.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            summary.videoTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(summary.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.summary,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
