import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _serverUrlController;

  @override
  void initState() {
    super.initState();
    final apiService = context.read<ApiService>();
    _serverUrlController = TextEditingController(text: apiService.baseUrl);
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  void _saveServerUrl() {
    final url = _serverUrlController.text.trim();
    if (url.isNotEmpty) {
      context.read<ApiService>().updateBaseUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 URL이 저장되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Server URL
          const Text(
            '서버 설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _serverUrlController,
            decoration: InputDecoration(
              labelText: 'API 서버 URL',
              hintText: 'http://localhost:8000/api/v1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _saveServerUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('저장'),
            ),
          ),
          const SizedBox(height: 32),
          // About
          const Text(
            '앱 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YouTube Helper',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('버전 1.0.0',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 12),
                  Text(
                    'YouTube 영상의 자막을 AI로 요약해주는 앱입니다.\n'
                    'Gemini AI를 활용하여 핵심 내용을 빠르게 파악할 수 있습니다.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
