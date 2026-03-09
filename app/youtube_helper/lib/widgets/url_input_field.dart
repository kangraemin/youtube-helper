import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UrlInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmit;
  final bool enabled;

  const UrlInputField({
    super.key,
    required this.controller,
    this.onSubmit,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: 'YouTube URL을 입력하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
            onSubmitted: (_) => onSubmit?.call(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed:
              enabled
                  ? () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      controller.text = data!.text!;
                    }
                  }
                  : null,
          icon: const Icon(Icons.paste),
          tooltip: '붙여넣기',
        ),
      ],
    );
  }
}
