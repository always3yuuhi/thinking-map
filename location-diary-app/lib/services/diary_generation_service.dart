import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../domain/timeline_segment.dart';

typedef PlaceLabelResolver = String Function(StaySegment stay);

/// Turns a day's detected stays/moves into a natural-language diary entry
/// (spec 3.4).
abstract class DiaryGenerationService {
  Future<String> generateDiary({
    required DateTime date,
    required List<TimelineSegment> segments,
    required PlaceLabelResolver placeLabel,
  });
}

class DiaryGenerationException implements Exception {
  DiaryGenerationException(this.message);

  final String message;

  @override
  String toString() => 'DiaryGenerationException: $message';
}

/// Calls the Claude API (Messages API) to write the diary entry.
class ClaudeDiaryGenerationService implements DiaryGenerationService {
  ClaudeDiaryGenerationService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-5';
  static const _anthropicVersion = '2023-06-01';

  @override
  Future<String> generateDiary({
    required DateTime date,
    required List<TimelineSegment> segments,
    required PlaceLabelResolver placeLabel,
  }) async {
    final summary = buildActivitySummary(date, segments, placeLabel);

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': _anthropicVersion,
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content':
                '以下は今日の行動記録です。この記録をもとに、一人称の自然な日本語の日記文を生成してください。'
                '時刻や場所を機械的に羅列するのではなく、実際に過ごした一日のような文章にしてください。\n\n$summary',
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw DiaryGenerationException(
        'Claude API returned ${response.statusCode}: ${response.body}',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>? ?? const [];
    final text = content
        .whereType<Map<String, dynamic>>()
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join('\n')
        .trim();

    if (text.isEmpty) {
      throw DiaryGenerationException('Claude API returned no text content');
    }
    return text;
  }
}

/// Offline stand-in used when no API key is configured yet, so the UI can
/// still be exercised end-to-end without network access or a key.
class MockDiaryGenerationService implements DiaryGenerationService {
  @override
  Future<String> generateDiary({
    required DateTime date,
    required List<TimelineSegment> segments,
    required PlaceLabelResolver placeLabel,
  }) async {
    final stayCount = segments.whereType<StaySegment>().length;
    final formatted = DateFormat('yyyy年M月d日').format(date);
    return '$formattedは$stayCount箇所を訪れました。'
        '(Claude APIキーが未設定のため、これは仮の日記です。設定画面でAPIキーを登録すると実際の日記が生成されます。)';
  }
}

/// Renders segments into the plain-text summary sent to the LLM.
String buildActivitySummary(
  DateTime date,
  List<TimelineSegment> segments,
  PlaceLabelResolver placeLabel,
) {
  final buffer = StringBuffer('日付: ${DateFormat('yyyy-MM-dd').format(date)}\n');
  final timeFormat = DateFormat('HH:mm');

  for (final segment in segments) {
    switch (segment) {
      case StaySegment():
        buffer.writeln(
          '- 滞在: ${placeLabel(segment)} '
          '(${timeFormat.format(segment.startTime)}〜${timeFormat.format(segment.endTime)}, '
          '${segment.duration.inMinutes}分)',
        );
      case MoveSegment():
        buffer.writeln(
          '- 移動: ${timeFormat.format(segment.startTime)}〜${timeFormat.format(segment.endTime)} '
          '(${segment.dominantActivity.name}, 約${segment.distanceMeters.round()}m)',
        );
    }
  }
  return buffer.toString();
}
