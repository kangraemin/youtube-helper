import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/features/summary/application/summary_providers.dart';
import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';
import 'package:youtube_helper/features/summary/presentation/widgets/chat_widget.dart';

final _summaryDetailProvider =
    FutureProvider.family<SummaryEntity?, String>((ref, id) async {
  return ref.read(summaryRepositoryProvider).getById(id);
});

class SummaryDetailScreen extends ConsumerStatefulWidget {
  final String summaryId;

  const SummaryDetailScreen({super.key, required this.summaryId});

  static const routePath = '/summary/:id';

  @override
  ConsumerState<SummaryDetailScreen> createState() =>
      _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends ConsumerState<SummaryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label 복사됨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(_summaryDetailProvider(widget.summaryId));
    final theme = Theme.of(context);

    return summaryAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('오류: $e')),
      ),
      data: (summary) {
        if (summary == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('요약을 찾을 수 없습니다')),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              summary.videoTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: theme.dividerColor.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
          ),
          body: Column(
            children: [
              // Thumbnail
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  summary.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),

              // Tab Bar
              Container(
                color: theme.appBarTheme.backgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: '요약'),
                    Tab(text: '스크립트 전문'),
                    Tab(text: '질문하기'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SummaryTab(summary: summary),
                    _TranscriptTab(summary: summary),
                    ChatWidget(summary: summary),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: ListenableBuilder(
            listenable: _tabController,
            builder: (context, _) {
              if (_tabController.index == 2) return const SizedBox.shrink();
              final text = _tabController.index == 0
                  ? summary.summary
                  : summary.transcript;
              final label = _tabController.index == 0 ? '요약' : '스크립트';
              return FloatingActionButton(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                onPressed: () => _copyToClipboard(text, label),
                child: const Icon(Icons.content_copy),
              );
            },
          ),
        );
      },
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final SummaryEntity summary;

  const _SummaryTab({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = summary.summary
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '동영상 요약',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary bullets
          ...lines.map((line) {
            final cleaned =
                line.replaceFirst(RegExp(r'^[-•*]\s*'), '').trim();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cleaned,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Transcript preview
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '스크립트 일부',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  '전체보기',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildTranscriptPreview(context),
        ],
      ),
    );
  }

  List<Widget> _buildTranscriptPreview(BuildContext context) {
    final theme = Theme.of(context);
    final lines = summary.transcript.split('\n').take(5).toList();

    return lines.map((line) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _TranscriptTab extends StatelessWidget {
  final SummaryEntity summary;

  const _TranscriptTab({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      child: SelectableText(
        summary.transcript,
        style: TextStyle(
          fontSize: 15,
          height: 1.8,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
