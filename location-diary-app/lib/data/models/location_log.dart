enum ActivityType { still, walking, vehicle, train, unknown }

ActivityType activityTypeFromString(String value) {
  return ActivityType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ActivityType.unknown,
  );
}

class LocationLog {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final ActivityType activityType;

  const LocationLog({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.activityType = ActivityType.unknown,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'activity_type': activityType.name,
    };
  }

  factory LocationLog.fromMap(Map<String, Object?> map) {
    return LocationLog(
      id: map['id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      activityType: activityTypeFromString(map['activity_type'] as String),
    );
  }
}
