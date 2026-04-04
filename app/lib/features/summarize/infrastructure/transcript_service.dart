import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube_helper/features/summarize/domain/entities/video_summary.dart';

class TranscriptService {
  static const _headers = {
    'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
  };

  static const _langPriority = ['ko', 'ko-auto', 'en', 'en-auto'];

  String extractVideoId(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) throw Exception('Invalid URL');

    final host = uri.host.replaceFirst('www.', '');

    if (host == 'youtube.com' || host == 'm.youtube.com') {
      if (uri.path == '/watch') {
        final id = uri.queryParameters['v'];
        if (id != null && id.isNotEmpty) return id;
      }
      if (uri.path.startsWith('/shorts/')) {
        final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (id != null && id.isNotEmpty) return id;
      }
      if (uri.path.startsWith('/live/')) {
        final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (id != null && id.isNotEmpty) return id;
      }
    }

    if (host == 'youtu.be') {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (id != null && id.isNotEmpty) return id;
    }

    throw Exception('유효한 YouTube URL이 아닙니다: $url');
  }

  Future<String> fetchVideoTitle(String videoId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json',
        ),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['title'] as String? ?? 'Unknown';
      }
    } catch (_) {}
    return 'Unknown';
  }

  Future<(List<TranscriptSegment>, String)> fetchTranscript(
      String videoId) async {
    // 1. YouTube 페이지 HTML 가져오기
    final pageResponse = await http.get(
      Uri.parse('https://www.youtube.com/watch?v=$videoId'),
      headers: _headers,
    );

    if (pageResponse.statusCode != 200) {
      throw Exception('YouTube 페이지를 불러올 수 없습니다 (${pageResponse.statusCode})');
    }

    final html = pageResponse.body;

    // 2. captionTracks 배열 추출
    final trackUrl = _selectCaptionTrackUrl(html);
    if (trackUrl == null) {
      throw Exception('이 영상에는 자막이 없습니다');
    }

    // 3. 자막 XML 가져오기
    final xmlResponse = await http.get(Uri.parse(trackUrl));
    if (xmlResponse.statusCode != 200) {
      throw Exception('자막을 불러올 수 없습니다');
    }

    // 4. XML 파싱
    final segments = _parseTranscriptXml(xmlResponse.body);
    final fullText = segments.map((s) => s.text).join(' ');

    return (segments, fullText);
  }

  String? _selectCaptionTrackUrl(String html) {
    // "captionTracks":[{...},{...}] 추출
    final match =
        RegExp(r'"captionTracks":(\[.*?\])', dotAll: true).firstMatch(html);
    if (match == null) return null;

    List<dynamic> tracks;
    try {
      tracks = jsonDecode(match.group(1)!) as List<dynamic>;
    } catch (_) {
      return null;
    }

    if (tracks.isEmpty) return null;

    // 언어 우선순위로 선택
    for (final lang in _langPriority) {
      for (final track in tracks) {
        final t = track as Map<String, dynamic>;
        final vssId = (t['vssId'] as String? ?? '').toLowerCase();
        final langCode = (t['languageCode'] as String? ?? '').toLowerCase();
        final isAuto = vssId.startsWith('a.');

        bool matches = false;
        if (lang.endsWith('-auto')) {
          matches =
              isAuto && langCode == lang.replaceAll('-auto', '');
        } else {
          matches = !isAuto && langCode == lang;
        }

        if (matches) {
          final baseUrl = t['baseUrl'] as String?;
          if (baseUrl != null) return baseUrl;
        }
      }
    }

    // 우선순위 매칭 없으면 첫 번째
    final first = tracks[0] as Map<String, dynamic>;
    return first['baseUrl'] as String?;
  }

  List<TranscriptSegment> _parseTranscriptXml(String xml) {
    final segments = <TranscriptSegment>[];
    // <text start="0.0" dur="2.5">...</text> 패턴
    final regex = RegExp(
      r'<text\s+start="([\d.]+)"\s+dur="([\d.]+)"[^>]*>(.*?)</text>',
      dotAll: true,
    );

    for (final match in regex.allMatches(xml)) {
      final start = double.tryParse(match.group(1)!) ?? 0;
      final duration = double.tryParse(match.group(2)!) ?? 0;
      final rawText = match.group(3)!;
      final text = _decodeHtmlEntities(rawText).trim();

      if (text.isNotEmpty) {
        segments.add(TranscriptSegment(
          text: text,
          start: start,
          duration: duration,
        ));
      }
    }

    return segments;
  }

  String _decodeHtmlEntities(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('\n', ' ');
  }
}
