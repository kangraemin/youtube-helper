import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SummaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SummaryButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppTheme.primaryRed.withValues(alpha: 0.6),
        ),
        child: Text(
          isLoading ? '요약 중...' : '\u2728 요약하기',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
