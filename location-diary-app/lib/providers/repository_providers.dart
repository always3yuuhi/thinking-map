import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/diary_repository.dart';
import '../data/repositories/location_log_repository.dart';
import '../data/repositories/place_alias_repository.dart';
import '../data/repositories/visited_place_repository.dart';

final locationLogRepositoryProvider = Provider<LocationLogRepository>((ref) {
  return LocationLogRepository();
});

final visitedPlaceRepositoryProvider = Provider<VisitedPlaceRepository>((
  ref,
) {
  return VisitedPlaceRepository();
});

final placeAliasRepositoryProvider = Provider<PlaceAliasRepository>((ref) {
  return PlaceAliasRepository();
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository();
});
