import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/diary_entry.dart';
import '../data/models/place_alias.dart';
import '../data/models/visited_place.dart';
import '../domain/geo_utils.dart';
import '../domain/stay_detection.dart';
import '../domain/timeline_segment.dart';
import 'repository_providers.dart';
import 'service_providers.dart';

/// Orchestrates the end-of-day pipeline (spec 3.4): detect the day's
/// stays/moves, resolve each stay's address and alias, persist them as
/// [VisitedPlace] rows, then ask the diary generation service to write the
/// entry and save it.
class DiaryGenerationController {
  DiaryGenerationController(this._ref);

  final Ref _ref;

  Future<DiaryEntry> generateForDate(DateTime date) async {
    final logRepo = _ref.read(locationLogRepositoryProvider);
    final visitedPlaceRepo = _ref.read(visitedPlaceRepositoryProvider);
    final aliasRepo = _ref.read(placeAliasRepositoryProvider);
    final diaryRepo = _ref.read(diaryRepositoryProvider);
    final geocoding = _ref.read(geocodingServiceProvider);
    final diaryService = _ref.read(diaryGenerationServiceProvider);

    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final logs = await logRepo.findBetween(dayStart, dayEnd);
    final segments = detectTimeline(logs);
    final aliases = await aliasRepo.findAll();

    final placeBySegment = <StaySegment, VisitedPlace>{};
    for (final segment in segments.whereType<StaySegment>()) {
      final address = await geocoding.reverseGeocode(
        segment.latitude,
        segment.longitude,
      );
      final alias = _findEnclosingAlias(
        aliases,
        segment.latitude,
        segment.longitude,
      );
      final place = VisitedPlace(
        startTime: segment.startTime,
        endTime: segment.endTime,
        latitude: segment.latitude,
        longitude: segment.longitude,
        resolvedAddress: address,
        aliasId: alias?.id,
      );
      final id = await visitedPlaceRepo.insert(place);
      placeBySegment[segment] = place.copyWith(id: id);
    }

    String placeLabel(StaySegment segment) {
      final place = placeBySegment[segment];
      final aliasId = place?.aliasId;
      if (aliasId != null) {
        for (final alias in aliases) {
          if (alias.id == aliasId) return alias.displayName;
        }
      }
      return place?.resolvedAddress ?? '不明な場所';
    }

    final body = await diaryService.generateDiary(
      date: date,
      segments: segments,
      placeLabel: placeLabel,
    );

    final entry = DiaryEntry(date: date, body: body, updatedAt: DateTime.now());
    final id = await diaryRepo.upsert(entry);
    return entry.copyWith(id: id);
  }

  PlaceAlias? _findEnclosingAlias(
    List<PlaceAlias> aliases,
    double latitude,
    double longitude,
  ) {
    for (final alias in aliases) {
      final distance = haversineDistanceMeters(
        alias.latitude,
        alias.longitude,
        latitude,
        longitude,
      );
      if (distance <= alias.radiusMeters) return alias;
    }
    return null;
  }
}

final diaryGenerationControllerProvider = Provider<DiaryGenerationController>(
  (ref) => DiaryGenerationController(ref),
);
