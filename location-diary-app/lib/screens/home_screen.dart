import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/diary_entry.dart';
import '../data/models/location_log.dart';
import '../domain/timeline_segment.dart';
import '../providers/diary_generation_controller.dart';
import '../providers/repository_providers.dart';
import '../providers/service_providers.dart';
import '../providers/timeline_providers.dart';
import 'diary_detail_screen.dart';

DateTime _todayDateOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _todayDateOnly();
    final timelineAsync = ref.watch(dailyTimelineProvider(today));
    final diaryAsync = ref.watch(diaryForDateProvider(today));

    return Scaffold(
      appBar: AppBar(title: const Text('今日の記録')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyTimelineProvider(today));
          ref.invalidate(diaryForDateProvider(today));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy年M月d日').format(today),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                FilledButton.icon(
                  onPressed: () => _recordCurrentLocation(context, ref, today),
                  icon: const Icon(Icons.my_location),
                  label: const Text('今すぐ記録'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            timelineAsync.when(
              data: (segments) => segments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'まだ位置情報の記録がありません。「今すぐ記録」で記録できます。'
                        '(バックグラウンド自動収集は実機での検証が必要です)',
                      ),
                    )
                  : Column(
                      children: [
                        for (final segment in segments)
                          _TimelineTile(segment: segment),
                      ],
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('読み込みエラー: $e'),
            ),
            const SizedBox(height: 24),
            diaryAsync.when(
              data: (entry) {
                if (entry != null) {
                  return _DiaryPreviewCard(entry: entry, date: today);
                }
                return FilledButton.icon(
                  onPressed: () => _generateDiary(context, ref, today),
                  icon: const Icon(Icons.auto_stories),
                  label: const Text('日記を生成する'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('読み込みエラー: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordCurrentLocation(
    BuildContext context,
    WidgetRef ref,
    DateTime today,
  ) async {
    final locationService = ref.read(locationServiceProvider);
    final logRepo = ref.read(locationLogRepositoryProvider);
    try {
      final position = await locationService.currentPosition();
      await logRepo.insert(
        LocationLog(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        ),
      );
      ref.invalidate(dailyTimelineProvider(today));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('位置情報を記録しました')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('記録に失敗しました: $e')));
      }
    }
  }

  Future<void> _generateDiary(
    BuildContext context,
    WidgetRef ref,
    DateTime today,
  ) async {
    final controller = ref.read(diaryGenerationControllerProvider);
    try {
      await controller.generateForDate(today);
      ref.invalidate(diaryForDateProvider(today));
      ref.invalidate(diaryEntriesProvider);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DiaryDetailScreen(date: today)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('日記の生成に失敗しました: $e')));
      }
    }
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.segment});

  final TimelineSegment segment;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return switch (segment) {
      StaySegment(:final startTime, :final endTime, :final duration) => ListTile(
        leading: const Icon(Icons.place),
        title: Text(
          '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
        ),
        subtitle: Text('滞在 ${duration.inMinutes}分'),
      ),
      MoveSegment(
        :final startTime,
        :final endTime,
        :final distanceMeters,
        :final dominantActivity,
      ) =>
        ListTile(
          leading: const Icon(Icons.directions_walk),
          title: Text(
            '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
          ),
          subtitle: Text(
            '移動 約${distanceMeters.round()}m (${dominantActivity.name})',
          ),
        ),
    };
  }
}

class _DiaryPreviewCard extends StatelessWidget {
  const _DiaryPreviewCard({required this.entry, required this.date});

  final DiaryEntry entry;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('今日の日記'),
        subtitle: Text(
          entry.body,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DiaryDetailScreen(date: date)),
        ),
      ),
    );
  }
}
