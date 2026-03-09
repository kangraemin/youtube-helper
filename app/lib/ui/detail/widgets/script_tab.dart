import 'package:flutter/material.dart';

class ScriptTab extends StatelessWidget {
  final String transcriptText;

  const ScriptTab({super.key, required this.transcriptText});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '자막 전문',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transcriptText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
