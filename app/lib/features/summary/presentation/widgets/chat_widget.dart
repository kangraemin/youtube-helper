import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_helper/features/summary/application/summary_providers.dart';
import 'package:youtube_helper/features/summary/domain/entities/summary_entity.dart';

class _ChatMessage {
  final String content;
  final bool isUser;

  _ChatMessage({required this.content, required this.isUser});
}

class ChatWidget extends ConsumerStatefulWidget {
  final SummaryEntity summary;

  const ChatWidget({super.key, required this.summary});

  @override
  ConsumerState<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(content: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final response = await ref.read(summaryApiServiceProvider).chat(
            question: text,
            transcript: widget.summary.transcript,
            summary: widget.summary.summary,
            history: history.sublist(0, history.length - 1),
          );

      setState(() {
        _messages.add(_ChatMessage(content: response.answer, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          content: '응답을 가져올 수 없습니다. 다시 시도해주세요.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '영상에 대해 궁금한 점을 질문해보세요',
                        style: TextStyle(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildLoadingBubble(theme);
                    }
                    final message = _messages[index];
                    return _buildMessageBubble(message, theme);
                  },
                ),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor,
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '질문을 입력하세요...',
                      hintStyle: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: _isLoading
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, ThemeData theme) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: SizedBox(
          width: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (i) => _DotAnimation(delay: i * 200),
            ),
          ),
        ),
      ),
    );
  }
}

class _DotAnimation extends StatefulWidget {
  final int delay;

  const _DotAnimation({required this.delay});

  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.2 + _animation.value * 0.3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
