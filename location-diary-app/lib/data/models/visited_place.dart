class VisitedPlace {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final double latitude;
  final double longitude;
  final String? resolvedAddress;
  final int? aliasId;

  const VisitedPlace({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    this.resolvedAddress,
    this.aliasId,
  });

  Duration get stayDuration => endTime.difference(startTime);

  VisitedPlace copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    double? latitude,
    double? longitude,
    String? resolvedAddress,
    int? aliasId,
  }) {
    return VisitedPlace(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      resolvedAddress: resolvedAddress ?? this.resolvedAddress,
      aliasId: aliasId ?? this.aliasId,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'resolved_address': resolvedAddress,
      'alias_id': aliasId,
    };
  }

  factory VisitedPlace.fromMap(Map<String, Object?> map) {
    return VisitedPlace(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      resolvedAddress: map['resolved_address'] as String?,
      aliasId: map['alias_id'] as int?,
    );
  }
}
