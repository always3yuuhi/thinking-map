import 'package:geolocator/geolocator.dart';

class LocationPermissionDenied implements Exception {
  const LocationPermissionDenied();

  @override
  String toString() => 'Location permission was denied';
}

/// Thin wrapper around `geolocator` for foreground/one-shot reads.
///
/// Background collection lives in [BackgroundLocationService]; this class
/// is what the UI uses for "record my location now" and permission prompts.
class LocationService {
  Future<void> ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationPermissionDenied();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDenied();
    }
  }

  Future<Position> currentPosition() async {
    await ensurePermissions();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
