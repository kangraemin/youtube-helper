import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();
    return Column(
      children: [
        Row(
          children: [
            const Text(
              '\u26A1 AI 요약 중...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.dividerColor,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
