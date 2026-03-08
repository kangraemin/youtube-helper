import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_summary.dart';
import '../providers/summary_provider.dart';

class DetailScreen extends StatefulWidget {
  final VideoSummary? summary;

  const DetailScreen({super.key, this.summary});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SummaryProvider>(
      builder: (context, provider, _) {
        final summary = widget.summary ?? provider.currentSummary;
        if (summary == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('상세')),
            body: const Center(child: Text('요약 데이터가 없습니다')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              summary.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              isScrollable: true,
              tabs: const [
                Tab(text: '스크립트 전문'),
                Tab(text: '동영상 요약'),
                Tab(text: '핵심 요점'),
                Tab(text: '챗봇'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTranscriptTab(summary.transcript),
              _buildSummaryTab(summary.summary),
              _buildKeyPointsTab(summary.keyPoints),
              _buildChatTab(provider),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFFF0000),
            foregroundColor: Colors.white,
            onPressed: () {
              _tabController.animateTo(3);
            },
            child: const Icon(Icons.chat),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptTab(String transcript) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        transcript.isNotEmpty ? transcript : '스크립트가 없습니다.',
        style: const TextStyle(fontSize: 15, height: 1.6),
      ),
    );
  }

  Widget _buildSummaryTab(String summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            summary.isNotEmpty ? summary : '요약이 없습니다.',
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyPointsTab(List<String> keyPoints) {
    if (keyPoints.isEmpty) {
      return const Center(child: Text('핵심 요점이 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keyPoints.length,
      itemBuilder: (context, index) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(keyPoints[index]),
          ),
        );
      },
    );
  }

  Widget _buildChatTab(SummaryProvider provider) {
    return Column(
      children: [
        Expanded(
          child: provider.chatMessages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        '영상에 대해 질문해보세요',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.chatMessages[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFFFF0000)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['content'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (provider.isChatLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(color: Color(0xFFFF0000)),
          ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(50),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: '질문을 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(provider),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFFFF0000),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(provider),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(SummaryProvider provider) {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    provider.sendChatMessage(text);
  }
}
