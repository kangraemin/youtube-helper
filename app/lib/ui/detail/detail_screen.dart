import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/video_summary.dart';
import '../../providers/chat_provider.dart';
import '../../providers/summary_provider.dart';
import 'widgets/summary_tab.dart';
import 'widgets/script_tab.dart';
import 'widgets/chat_bottom_sheet.dart';

class DetailScreen extends StatelessWidget {
  final String videoId;

  const DetailScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<SummaryProvider>().currentSummary;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('상세')),
        body: const Center(child: Text('요약 데이터를 찾을 수 없습니다')),
      );
    }

    return _DetailContent(summary: summary);
  }
}

class _DetailContent extends StatelessWidget {
  final VideoSummary summary;

  const _DetailContent({required this.summary});

  void _openChat(BuildContext context) {
    context.read<ChatProvider>().initChat(
          videoId: summary.videoId,
          transcriptText: summary.transcriptText,
        );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ChatProvider>(),
        child: const ChatBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            summary.title,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: '요약'),
              Tab(text: '스크립트'),
              Tab(text: '전문'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SummaryTab(summary: summary),
            ScriptTab(transcriptText: summary.transcriptText),
            // Full view - same as script for now
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전체 내용',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(summary.summary),
                  const SizedBox(height: 24),
                  if (summary.keyPoints.isNotEmpty) ...[
                    const Text(
                      '핵심 요점',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...summary.keyPoints.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('- $p'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    '스크립트',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.transcriptText,
                    style: const TextStyle(height: 1.8),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openChat(context),
          backgroundColor: AppTheme.primaryRed,
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
    );
  }
}
