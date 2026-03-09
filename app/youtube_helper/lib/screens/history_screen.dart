import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/history_provider.dart';
import '../models/video_summary.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('히스토리',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: entries.isEmpty ? _buildEmptyState() : _buildList(context, entries),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('아직 요약한 영상이 없어요',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('유튜브 영상 링크를 복사해와서 첫 요약을 시작해보세요!',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<HistoryEntry> entries) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('최근 요약 기록',
            style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...entries.map((entry) => _buildHistoryItem(context, entry)),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryEntry entry) {
    final now = DateTime.now();
    final diff = now.difference(entry.createdAt);
    String timeLabel;
    if (diff.inMinutes < 60) {
      timeLabel = '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      timeLabel = '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      timeLabel = '${diff.inDays}일 전';
    } else {
      timeLabel = '${entry.createdAt.year}.${entry.createdAt.month.toString().padLeft(2, '0')}.${entry.createdAt.day.toString().padLeft(2, '0')}';
    }

    return GestureDetector(
      onTap: () {
        context.push('/detail', extra: entry);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: entry.thumbnailUrl,
                width: 80,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(width: 80, height: 60, color: Colors.grey.shade200),
                errorWidget: (context, url, error) =>
                    Container(width: 80, height: 60, color: Colors.grey.shade200,
                        child: const Icon(Icons.error, size: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      Text(timeLabel,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(entry.summaryPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
