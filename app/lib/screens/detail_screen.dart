import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/video_summary.dart';
import '../widgets/summary_section.dart';
import 'chat_screen.dart';

class DetailScreen extends StatelessWidget {
  final VideoSummary video;

  const DetailScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: const TabBar(
            labelColor: Colors.red,
            indicatorColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: '요약'),
              Tab(text: '스크립트'),
              Tab(text: '전문'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSummaryTab(),
            _buildTranscriptTab(),
            _buildFullSummaryTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(video: video),
              ),
            );
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (video.summary != null) ...[
            SummarySection(
              title: '동영상 요약',
              icon: Icons.summarize,
              points: video.summary!
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          if (video.keyPoints != null && video.keyPoints!.isNotEmpty)
            SummarySection(
              title: '핵심 포인트',
              icon: Icons.lightbulb_outline,
              points: video.keyPoints!,
            ),
        ],
      ),
    );
  }

  Widget _buildTranscriptTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: video.transcript.length,
      itemBuilder: (context, index) {
        final segment = video.transcript[index];
        final minutes = (segment.start ~/ 60).toString().padLeft(2, '0');
        final seconds =
            (segment.start.toInt() % 60).toString().padLeft(2, '0');
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$minutes:$seconds',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  segment.text,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullSummaryTab() {
    final content = video.fullSummary ?? video.summary ?? '요약 내용이 없습니다.';
    return Markdown(
      data: content,
      padding: const EdgeInsets.all(16),
    );
  }
}
