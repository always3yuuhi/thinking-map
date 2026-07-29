import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/diary_entry.dart';
import '../data/models/place_alias.dart';
import '../data/models/visited_place.dart';
import '../domain/stay_detection.dart';
import '../domain/timeline_segment.dart';
import 'repository_providers.dart';

/// Detected stays/moves for a given calendar day, computed on demand from
/// the raw location log (spec 3.2/3.3). Not persisted — cheap enough to
/// recompute, and always reflects the latest raw pings.
final dailyTimelineProvider = FutureProvider.family<List<TimelineSegment>, DateTime>((
  ref,
  date,
) async {
  final repo = ref.watch(locationLogRepositoryProvider);
  final dayStart = DateTime(date.year, date.month, date.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final logs = await repo.findBetween(dayStart, dayEnd);
  return detectTimeline(logs);
});

final placeAliasesProvider = FutureProvider<List<PlaceAlias>>((ref) async {
  final repo = ref.watch(placeAliasRepositoryProvider);
  return repo.findAll();
});

final diaryEntriesProvider = FutureProvider<List<DiaryEntry>>((ref) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.findAll();
});

final diaryForDateProvider = FutureProvider.family<DiaryEntry?, DateTime>((
  ref,
  date,
) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.findByDate(date);
});

/// Visited places persisted for a day (created when the diary is generated
/// — see [DiaryGenerationController]), shown on the diary detail screen.
final visitedPlacesForDateProvider =
    FutureProvider.family<List<VisitedPlace>, DateTime>((ref, date) async {
      final repo = ref.watch(visitedPlaceRepositoryProvider);
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      return repo.findBetween(dayStart, dayEnd);
    });
