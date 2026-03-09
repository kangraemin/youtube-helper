import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UrlInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const UrlInputField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      controller.text = data!.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: 'YouTube URL을 입력하세요',
        prefixIcon: const Icon(Icons.link),
        suffixIcon: IconButton(
          icon: const Icon(Icons.content_paste),
          onPressed: enabled ? _pasteFromClipboard : null,
          tooltip: '클립보드에서 붙여넣기',
        ),
      ),
      keyboardType: TextInputType.url,
    );
  }
}
