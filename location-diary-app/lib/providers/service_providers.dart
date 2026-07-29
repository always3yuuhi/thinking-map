import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_key_storage.dart';
import '../services/background_location_service.dart';
import '../services/diary_generation_service.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final backgroundLocationServiceProvider = Provider<BackgroundLocationService>(
  (ref) {
    return BackgroundLocationService();
  },
);

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return NominatimGeocodingService();
});

final apiKeyStorageProvider = Provider<ApiKeyStorage>((ref) {
  return ApiKeyStorage();
});

/// Claude API key, kept in provider state so screens can react to it being
/// set/cleared without re-reading secure storage on every build.
final claudeApiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(apiKeyStorageProvider);
  return storage.readClaudeApiKey();
});

/// Falls back to [MockDiaryGenerationService] until a Claude API key is
/// configured, so the diary screens work end-to-end before phase 2 wires up
/// real generation for everyone.
final diaryGenerationServiceProvider = Provider<DiaryGenerationService>((
  ref,
) {
  final apiKey = ref.watch(claudeApiKeyProvider).valueOrNull;
  if (apiKey == null || apiKey.isEmpty) {
    return MockDiaryGenerationService();
  }
  return ClaudeDiaryGenerationService(apiKey: apiKey);
});
