import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/diary_entry.dart';
import '../data/models/place_alias.dart';
import '../data/models/visited_place.dart';
import '../providers/repository_providers.dart';
import '../providers/timeline_providers.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  const DiaryDetailScreen({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
  final _bodyController = TextEditingController();
  bool _loadedInitialBody = false;
  bool _saving = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryAsync = ref.watch(diaryForDateProvider(widget.date));
    final placesAsync = ref.watch(visitedPlacesForDateProvider(widget.date));
    final aliasesAsync = ref.watch(placeAliasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年M月d日').format(widget.date)),
      ),
      body: diaryAsync.when(
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('この日の日記はまだありません'));
          }
          if (!_loadedInitialBody) {
            _bodyController.text = entry.body;
            _loadedInitialBody = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _bodyController,
                maxLines: null,
                minLines: 6,
                decoration: const InputDecoration(
                  labelText: '本文',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _saving ? null : () => _save(entry),
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存'),
                ),
              ),
              const SizedBox(height: 24),
              Text('訪問地点', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              placesAsync.when(
                data: (places) => aliasesAsync.when(
                  data: (aliases) => _VisitedPlacesList(
                    places: places,
                    aliases: aliases,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('読み込みエラー: $e'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('読み込みエラー: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('読み込みエラー: $e')),
      ),
    );
  }

  Future<void> _save(DiaryEntry entry) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(diaryRepositoryProvider);
      await repo.upsert(
        entry.copyWith(
          body: _bodyController.text,
          manuallyEdited: true,
          updatedAt: DateTime.now(),
        ),
      );
      ref.invalidate(diaryForDateProvider(widget.date));
      ref.invalidate(diaryEntriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存しました')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _VisitedPlacesList extends StatelessWidget {
  const _VisitedPlacesList({required this.places, required this.aliases});

  final List<VisitedPlace> places;
  final List<PlaceAlias> aliases;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const Text('記録された訪問地点はありません');
    }
    final timeFormat = DateFormat('HH:mm');
    return Column(
      children: [
        for (final place in places)
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(_labelFor(place)),
            subtitle: Text(
              '${timeFormat.format(place.startTime)} - ${timeFormat.format(place.endTime)}'
              ' (${place.stayDuration.inMinutes}分)',
            ),
          ),
      ],
    );
  }

  String _labelFor(VisitedPlace place) {
    if (place.aliasId != null) {
      for (final alias in aliases) {
        if (alias.id == place.aliasId) return alias.displayName;
      }
    }
    return place.resolvedAddress ?? '不明な場所';
  }
}
