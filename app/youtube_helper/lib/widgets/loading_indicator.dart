import 'package:flutter/material.dart';

class SummaryLoadingIndicator extends StatelessWidget {
  final double progress;
  final String message;

  const SummaryLoadingIndicator({
    super.key,
    required this.progress,
    this.message = 'AI 요약 중...',
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '$message $percentage%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
