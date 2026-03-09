import 'package:flutter/material.dart';
import '../../models/video_summary.dart';
import '../chat/chat_screen.dart';

class DetailScreen extends StatelessWidget {
  final VideoSummary summary;

  const DetailScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            summary.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFFF4444),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF4444),
            tabs: [
              Tab(text: '요약'),
              Tab(text: '스크립트'),
              Tab(text: '전문'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SummaryTab(summary: summary),
            _ScriptTab(summary: summary),
            _FullTextTab(summary: summary),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  videoTitle: summary.title,
                  videoUrl:
                      'https://www.youtube.com/watch?v=${summary.videoId}',
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFFFF4444),
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final VideoSummary summary;
  const _SummaryTab({required this.summary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('동영상 요약', [
            Text(summary.summary,
                style: const TextStyle(fontSize: 15, height: 1.6)),
          ]),
          const SizedBox(height: 24),
          _buildSection('핵심 포인트', [
            for (var i = 0; i < summary.keyPoints.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        summary.keyPoints[i],
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ]),
          const SizedBox(height: 24),
          _buildSection('활용 방법', [
            for (final tip in summary.tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(fontSize: 16, color: Color(0xFFFF4444))),
                    Expanded(
                      child: Text(tip,
                          style: const TextStyle(fontSize: 14, height: 1.5)),
                    ),
                  ],
                ),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _ScriptTab extends StatelessWidget {
  final VideoSummary summary;
  const _ScriptTab({required this.summary});

  @override
  Widget build(BuildContext context) {
    final segments = summary.segments;
    if (segments == null || segments.isEmpty) {
      return const Center(child: Text('스크립트가 없습니다'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: segments.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final segment = segments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  segment.formattedTime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  segment.text,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FullTextTab extends StatelessWidget {
  final VideoSummary summary;
  const _FullTextTab({required this.summary});

  @override
  Widget build(BuildContext context) {
    final fullText = summary.fullText;
    if (fullText == null || fullText.isEmpty) {
      return const Center(child: Text('전문 텍스트가 없습니다'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(fullText, style: const TextStyle(fontSize: 14, height: 1.8)),
    );
  }
}
