import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import '../data/models/location_log.dart';
import '../data/repositories/location_log_repository.dart';

/// Configures the Android foreground service that periodically records the
/// device's location (spec 3.1, default 5 minute interval).
///
/// This is wiring only — background execution cannot be exercised in this
/// development container (no Android device/emulator). It must be tested on
/// a real device; see location-diary-app/README.md.
class BackgroundLocationService {
  static const Duration defaultInterval = Duration(minutes: 5);

  Future<void> configure() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_diary_tracking',
        initialNotificationTitle: '位置情報日記',
        initialNotificationContent: '位置情報を記録しています',
      ),
      iosConfiguration: IosConfiguration(onForeground: _onStart),
    );
  }

  Future<void> start() async {
    await FlutterBackgroundService().startService();
  }

  Future<void> stop() async {
    FlutterBackgroundService().invoke('stop');
  }

  Future<bool> isRunning() => FlutterBackgroundService().isRunning();

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    final repository = LocationLogRepository();

    Timer.periodic(defaultInterval, (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        await repository.insert(
          LocationLog(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
          ),
        );
      } catch (_) {
        // Best-effort: skip this tick (e.g. no GPS fix yet, permission
        // revoked mid-session). The next tick will retry.
      }
    });

    service.on('stop').listen((event) {
      service.stopSelf();
    });
  }
}
