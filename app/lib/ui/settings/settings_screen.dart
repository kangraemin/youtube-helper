import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection('일반', [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('언어'),
              subtitle: const Text('한국어'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('테마'),
              subtitle: const Text('라이트'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
          _buildSection('데이터', [
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('캐시 초기화'),
              subtitle: const Text('저장된 요약 데이터 삭제'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
          _buildSection('정보', [
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('버전'),
              subtitle: Text('1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
