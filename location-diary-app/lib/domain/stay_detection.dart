import '../data/models/location_log.dart';
import 'geo_utils.dart';
import 'timeline_segment.dart';

/// Splits a day's raw location pings into alternating stay/move segments
/// (spec 3.2 訪問地点の自動検出, 3.3 移動区間の検出).
///
/// Pure Dart, no platform dependencies — points whose clock order is not
/// already sorted are sorted defensively so callers can pass raw DB reads.
List<TimelineSegment> detectTimeline(
  List<LocationLog> logs, {
  double stayRadiusMeters = 150,
  Duration minStayDuration = const Duration(minutes: 5),
}) {
  if (logs.isEmpty) return [];
  final sorted = [...logs]
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final clusters = _clusterByProximity(sorted, stayRadiusMeters);

  final segments = <TimelineSegment>[];
  var pendingMovePoints = <LocationLog>[];

  void flushPendingMove() {
    final segment = _buildMoveSegment(pendingMovePoints);
    if (segment != null) segments.add(segment);
    pendingMovePoints = [];
  }

  for (final cluster in clusters) {
    final span = cluster.last.timestamp.difference(cluster.first.timestamp);
    if (span >= minStayDuration) {
      flushPendingMove();
      segments.add(_buildStaySegment(cluster));
    } else {
      pendingMovePoints.addAll(cluster);
    }
  }
  flushPendingMove();

  return segments;
}

/// Groups consecutive points that stay within [stayRadiusMeters] of the
/// first point of the current cluster.
List<List<LocationLog>> _clusterByProximity(
  List<LocationLog> sorted,
  double stayRadiusMeters,
) {
  final clusters = <List<LocationLog>>[];
  var current = <LocationLog>[sorted.first];
  for (final point in sorted.skip(1)) {
    final anchor = current.first;
    final distance = haversineDistanceMeters(
      anchor.latitude,
      anchor.longitude,
      point.latitude,
      point.longitude,
    );
    if (distance <= stayRadiusMeters) {
      current.add(point);
    } else {
      clusters.add(current);
      current = [point];
    }
  }
  clusters.add(current);
  return clusters;
}

StaySegment _buildStaySegment(List<LocationLog> cluster) {
  final lat =
      cluster.map((p) => p.latitude).reduce((a, b) => a + b) /
      cluster.length;
  final lng =
      cluster.map((p) => p.longitude).reduce((a, b) => a + b) /
      cluster.length;
  return StaySegment(
    startTime: cluster.first.timestamp,
    endTime: cluster.last.timestamp,
    latitude: lat,
    longitude: lng,
  );
}

MoveSegment? _buildMoveSegment(List<LocationLog> points) {
  if (points.length < 2) return null;

  var distance = 0.0;
  for (var i = 1; i < points.length; i++) {
    final a = points[i - 1];
    final b = points[i];
    distance += haversineDistanceMeters(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  final activityCounts = <ActivityType, int>{};
  for (final p in points) {
    activityCounts[p.activityType] = (activityCounts[p.activityType] ?? 0) + 1;
  }
  final dominant = activityCounts.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;

  return MoveSegment(
    startTime: points.first.timestamp,
    endTime: points.last.timestamp,
    distanceMeters: distance,
    dominantActivity: dominant,
  );
}
