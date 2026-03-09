import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_summary.dart';
import '../providers/video_provider.dart';

class DetailScreen extends StatefulWidget {
  final VideoSummary video;

  const DetailScreen({super.key, required this.video});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isChatLoading = false;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final question = _chatController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': question});
      _isChatLoading = true;
    });
    _chatController.clear();

    try {
      final answer =
          await context.read<VideoProvider>().askQuestion(question);
      setState(() {
        _messages.add({'role': 'assistant', 'content': answer});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '오류가 발생했습니다: ${e.toString()}',
        });
      });
    } finally {
      setState(() {
        _isChatLoading = false;
      });
    }
  }

  void _showChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SizedBox(
                height: 400,
                child: Column(
                  children: [
                    const Text(
                      'AI에게 질문하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: Text(
                                '영상에 대해 궁금한 점을 물어보세요',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _messages.length,
                              itemBuilder: (_, index) {
                                final msg = _messages[index];
                                final isUser = msg['role'] == 'user';
                                return Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? const Color(0xFFE53935)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      msg['content']!,
                                      style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_isChatLoading) const LinearProgressIndicator(),
                    Row(
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
                            onSubmitted: (_) async {
                              await _sendMessage();
                              setSheetState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFE53935)),
                          onPressed: () async {
                            await _sendMessage();
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFE53935),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFE53935),
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
            _buildScriptTab(),
            _buildFullTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showChatSheet,
          backgroundColor: const Color(0xFFE53935),
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
          const Text(
            '동영상 요약',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.video.summary ?? '요약이 없습니다.',
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          if (widget.video.keyPoints != null &&
              widget.video.keyPoints!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              '핵심 포인트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.video.keyPoints!.map(
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

  Widget _buildScriptTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.video.transcript,
        style: const TextStyle(fontSize: 14, height: 1.8),
      ),
    );
  }

  Widget _buildFullTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.video.summary != null) ...[
            const Text(
              '요약',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.video.summary!,
                style: const TextStyle(fontSize: 15, height: 1.6)),
            const Divider(height: 32),
          ],
          const Text(
            '전체 스크립트',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.video.transcript,
            style: const TextStyle(fontSize: 14, height: 1.8),
          ),
        ],
      ),
    );
  }
}
