import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/video_summary.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/video_card.dart';
import '../widgets/loading_indicator.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;
  final StorageService storageService;

  const HomeScreen({
    super.key,
    required this.apiService,
    required this.storageService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  double _progress = 0.0;
  VideoSummary? _result;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  Future<void> _summarize() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _error = null;
      _result = null;
    });

    // Simulate progress
    _simulateProgress();

    try {
      final result = await widget.apiService.processVideo(url);
      await widget.storageService.addToHistory(result);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
          _progress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _simulateProgress() async {
    for (var i = 1; i <= 9; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isLoading || !mounted) return;
      setState(() {
        _progress = i * 0.1;
      });
    }
  }

  void _navigateToDetail(VideoSummary summary) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          summary: summary,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  void _copyToClipboard() {
    if (_result != null) {
      Clipboard.setData(ClipboardData(text: _result!.summary));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('요약이 복사되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.play_circle_fill, color: const Color(0xFFFF3B30)),
            const SizedBox(width: 8),
            const Text('YouTube Helper'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Switch to history tab via callback
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'YouTube URL을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: _pasteFromClipboard,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _summarize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '✦ 요약하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) LoadingIndicator(progress: _progress),
            if (_error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ),
            if (_result != null)
              VideoCard(
                summary: _result!,
                onTap: () => _navigateToDetail(_result!),
                onCopy: _copyToClipboard,
              ),
          ],
        ),
      ),
    );
  }
}
