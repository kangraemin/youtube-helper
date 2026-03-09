import 'package:flutter/material.dart';
import '../models/video_summary.dart';
import '../services/api_service.dart';

class DetailScreen extends StatelessWidget {
  final VideoSummary summary;
  final ApiService apiService;

  const DetailScreen({
    super.key,
    required this.summary,
    required this.apiService,
  });

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ChatSheet(
        summary: summary,
        apiService: apiService,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFFF3B30),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF3B30),
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
            _ScriptTab(transcript: summary.transcript),
            _FullTab(sections: summary.sections),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openChat(context),
          backgroundColor: const Color(0xFFFF3B30),
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
          const Text(
            '동영상 요약',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            summary.summary,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          if (summary.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              '핵심 포인트',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...summary.keyPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScriptTab extends StatelessWidget {
  final String transcript;

  const _ScriptTab({required this.transcript});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        transcript,
        style: const TextStyle(fontSize: 14, height: 1.8),
      ),
    );
  }
}

class _FullTab extends StatelessWidget {
  final List<Section> sections;

  const _FullTab({required this.sections});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(child: Text('섹션 정보가 없습니다'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections
            .map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.content,
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChatSheet extends StatefulWidget {
  final VideoSummary summary;
  final ApiService apiService;

  const _ChatSheet({required this.summary, required this.apiService});

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _history = [];
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isSending = true;
    });
    _messageController.clear();

    try {
      final reply = await widget.apiService.chat(
        widget.summary.videoId,
        widget.summary.transcript,
        text,
        _history,
      );
      _history.add({'role': 'user', 'content': text});
      _history.add({'role': 'assistant', 'content': reply});
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: reply, isUser: false));
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
              _ChatMessage(text: '오류가 발생했습니다: $e', isUser: false));
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '영상에 대해 질문하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (_, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? const Color(0xFFFF3B30)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isSending) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '질문을 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: const Color(0xFFFF3B30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
