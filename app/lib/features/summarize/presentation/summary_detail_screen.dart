import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:youtube_helper/features/summarize/application/summary_provider.dart';
import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';

class SummaryDetailScreen extends ConsumerStatefulWidget {
  final String videoId;

  const SummaryDetailScreen({super.key, required this.videoId});

  @override
  ConsumerState<SummaryDetailScreen> createState() =>
      _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends ConsumerState<SummaryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds.toInt() % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(summaryNotifierProvider);
    final summary = summaryState.result;
    final theme = Theme.of(context);

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('요약 데이터를 찾을 수 없습니다')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isTranscriptTab = _tabController.index == 1;
          final text = isTranscriptTab ? summary.fullText : summary.summary;
          final label = isTranscriptTab ? '스크립트가' : '요약이';
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label 복사되었습니다')),
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
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: '요약'),
              Tab(text: '스크립트 전문'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(summary, theme),
                _buildTranscriptTab(summary, theme),
              ],
            ),
          ),
          _buildChatSection(theme),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(VideoSummary summary, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '동영상 요약',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MarkdownBody(data: summary.summary),
        ],
      ),
    );
  }

  Widget _buildTranscriptTab(VideoSummary summary, ThemeData theme) {
    if (summary.transcriptSegments.isEmpty) {
      return const Center(child: Text('스크립트가 없습니다'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: summary.transcriptSegments.length,
      itemBuilder: (context, index) {
        final segment = summary.transcriptSegments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  segment.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatSection(ThemeData theme) {
    final summaryState = ref.watch(summaryNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (summaryState.chatMessages.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: summaryState.chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = summaryState.chatMessages[index];
                  final isUser = msg.role == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                      ),
                      child: Text(
                        msg.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isUser
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: '영상에 대해 질문하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: summaryState.isLoading
                      ? null
                      : () {
                          final text = _chatController.text.trim();
                          if (text.isEmpty) return;
                          ref
                              .read(summaryNotifierProvider.notifier)
                              .sendChat(text);
                          _chatController.clear();
                        },
                  icon: const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
