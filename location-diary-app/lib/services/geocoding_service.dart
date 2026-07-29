import 'dart:convert';

import 'package:http/http.dart' as http;

/// Resolves coordinates to a human-readable address (spec 3.2).
abstract class GeocodingService {
  Future<String?> reverseGeocode(double latitude, double longitude);
}

/// Default implementation using OpenStreetMap's Nominatim, which needs no
/// API key. Nominatim's usage policy caps free use at ~1 request/second and
/// requires a descriptive User-Agent; fine for one visited place at a time,
/// but swap in Google Geocoding API (implement [GeocodingService]) if this
/// app's usage grows beyond personal scale.
class NominatimGeocodingService implements GeocodingService {
  NominatimGeocodingService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '$latitude',
      'lon': '$longitude',
      'format': 'jsonv2',
    });
    final response = await _client.get(
      uri,
      headers: {'User-Agent': 'location-diary-app/1.0 (personal use)'},
    );
    if (response.statusCode != 200) return null;

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return data['display_name'] as String?;
  }
}
