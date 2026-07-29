class PlaceAlias {
  final int? id;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String displayName;

  const PlaceAlias({
    this.id,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
    required this.displayName,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'display_name': displayName,
    };
  }

  factory PlaceAlias.fromMap(Map<String, Object?> map) {
    return PlaceAlias(
      id: map['id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      radiusMeters: map['radius_meters'] as double,
      displayName: map['display_name'] as String,
    );
  }
}
