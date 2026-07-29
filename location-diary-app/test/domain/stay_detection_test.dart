import 'package:flutter_test/flutter_test.dart';
import 'package:location_diary_app/data/models/location_log.dart';
import 'package:location_diary_app/domain/stay_detection.dart';
import 'package:location_diary_app/domain/timeline_segment.dart';

LocationLog _log(String isoTime, double lat, double lng, {ActivityType a = ActivityType.unknown}) {
  return LocationLog(
    latitude: lat,
    longitude: lng,
    timestamp: DateTime.parse(isoTime),
    activityType: a,
  );
}

void main() {
  group('detectTimeline', () {
    test('returns empty list for no logs', () {
      expect(detectTimeline([]), isEmpty);
    });

    test('a single cluster spanning >= minStayDuration becomes one stay', () {
      final logs = [
        _log('2026-07-29T09:00:00', 35.681, 139.767),
        _log('2026-07-29T09:03:00', 35.6811, 139.7671),
        _log('2026-07-29T09:06:00', 35.6809, 139.7669),
        _log('2026-07-29T09:10:00', 35.681, 139.767),
      ];

      final segments = detectTimeline(logs);

      expect(segments, hasLength(1));
      expect(segments.single, isA<StaySegment>());
      final stay = segments.single as StaySegment;
      expect(stay.startTime, DateTime.parse('2026-07-29T09:00:00'));
      expect(stay.endTime, DateTime.parse('2026-07-29T09:10:00'));
    });

    test('stay -> move -> stay produces three alternating segments', () {
      final logs = [
        // Stay at point A for 10 minutes.
        _log('2026-07-29T08:00:00', 35.681, 139.767),
        _log('2026-07-29T08:05:00', 35.681, 139.767),
        _log('2026-07-29T08:10:00', 35.681, 139.767),
        // Movement away from A towards B (each point further away).
        _log(
          '2026-07-29T08:15:00',
          35.69,
          139.78,
          a: ActivityType.walking,
        ),
        _log(
          '2026-07-29T08:25:00',
          35.70,
          139.79,
          a: ActivityType.walking,
        ),
        // Stay at point B for 10 minutes.
        _log('2026-07-29T08:35:00', 35.71, 139.80),
        _log('2026-07-29T08:40:00', 35.71, 139.80),
        _log('2026-07-29T08:45:00', 35.71, 139.80),
      ];

      final segments = detectTimeline(logs, stayRadiusMeters: 150);

      expect(segments.map((s) => s.runtimeType), [
        StaySegment,
        MoveSegment,
        StaySegment,
      ]);

      final move = segments[1] as MoveSegment;
      expect(move.distanceMeters, greaterThan(0));
      expect(move.dominantActivity, ActivityType.walking);

      final firstStay = segments[0] as StaySegment;
      final secondStay = segments[2] as StaySegment;
      expect(firstStay.startTime, DateTime.parse('2026-07-29T08:00:00'));
      expect(secondStay.endTime, DateTime.parse('2026-07-29T08:45:00'));
    });

    test('scattered points with no dwell time produce a single move segment', () {
      final logs = [
        _log('2026-07-29T12:00:00', 35.0, 139.0, a: ActivityType.vehicle),
        _log('2026-07-29T12:01:00', 35.01, 139.01, a: ActivityType.vehicle),
        _log('2026-07-29T12:02:00', 35.02, 139.02, a: ActivityType.vehicle),
      ];

      final segments = detectTimeline(logs);

      expect(segments, hasLength(1));
      expect(segments.single, isA<MoveSegment>());
    });

    test('unsorted input is sorted defensively before processing', () {
      final logs = [
        _log('2026-07-29T09:10:00', 35.681, 139.767),
        _log('2026-07-29T09:00:00', 35.681, 139.767),
        _log('2026-07-29T09:05:00', 35.681, 139.767),
      ];

      final segments = detectTimeline(logs);

      expect(segments, hasLength(1));
      final stay = segments.single as StaySegment;
      expect(stay.startTime, DateTime.parse('2026-07-29T09:00:00'));
      expect(stay.endTime, DateTime.parse('2026-07-29T09:10:00'));
    });
  });
}
