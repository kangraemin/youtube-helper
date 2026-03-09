import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double progress;

  const LoadingIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)),
          minHeight: 6,
        ),
        const SizedBox(height: 8),
        Text(
          'AI 요약 중... $percentage%',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
