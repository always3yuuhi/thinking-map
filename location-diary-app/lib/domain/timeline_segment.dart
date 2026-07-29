import '../data/models/location_log.dart';

sealed class TimelineSegment {
  final DateTime startTime;
  final DateTime endTime;

  const TimelineSegment({required this.startTime, required this.endTime});

  Duration get duration => endTime.difference(startTime);
}

/// A period spent stationary in roughly one place (spec 3.2).
class StaySegment extends TimelineSegment {
  final double latitude;
  final double longitude;

  const StaySegment({
    required super.startTime,
    required super.endTime,
    required this.latitude,
    required this.longitude,
  });
}

/// A period of movement between two stays (spec 3.3).
class MoveSegment extends TimelineSegment {
  final double distanceMeters;
  final ActivityType dominantActivity;

  const MoveSegment({
    required super.startTime,
    required super.endTime,
    required this.distanceMeters,
    required this.dominantActivity,
  });
}
