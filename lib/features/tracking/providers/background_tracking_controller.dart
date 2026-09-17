import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/models/trip.dart';
import '../data/background_location_service.dart';

final backgroundTrackingProvider = Provider<BackgroundTracking>((ref) {
  return const BackgroundTracking();
});

/// Bridges Riverpod state to the background location service: it decides when a
/// trip should be tracked and makes sure the required permissions are granted.
class BackgroundTracking {
  const BackgroundTracking();

  /// Starts tracking for [active] when it is an in-progress trip, otherwise
  /// stops any running tracking. Call whenever the active trip may have changed.
  Future<void> syncActiveTrip(Trip? active) async {
    if (kIsWeb || !AppConfig.backgroundTrackingEnabled) return;
    if (active != null && active.status.canShareLocation) {
      final granted = await _ensurePermission();
      if (!granted) return;
      await BackgroundLocationService.startForTrip(active.id);
    } else {
      await BackgroundLocationService.stop();
    }
  }

  /// Stops tracking outright (e.g. on logout).
  Future<void> stop() => BackgroundLocationService.stop();

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    // Best-effort escalation to "always" so tracking survives backgrounding.
    if (permission == LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
    }
    return true;
  }
}
