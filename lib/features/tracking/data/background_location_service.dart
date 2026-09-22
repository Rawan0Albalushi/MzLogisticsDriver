import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';

/// Drives automatic driver-location sharing from a background isolate.
///
/// On Android the work runs inside a foreground service, so it keeps posting
/// location fixes for the active trip even after the app is backgrounded or the
/// task is swiped away. On iOS continuous updates run while the app is
/// backgrounded (via the `location` background mode); iOS does not permit
/// continuous execution once the app is force-quit, so it falls back to the
/// throttled background-fetch handler.
class BackgroundLocationService {
  const BackgroundLocationService._();

  static const int _notificationId = 8461;

  /// Wires up the background service. Safe to call once at app start-up; it does
  /// not start location capture until [startForTrip] is invoked.
  static Future<void> initialize() async {
    if (kIsWeb || !AppConfig.backgroundTrackingEnabled) return;
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        autoStartOnBoot: false,
        notificationChannelId: AppConfig.trackingChannelId,
        initialNotificationTitle: 'MoveX',
        initialNotificationContent: 'Sharing your live location for the trip.',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: const [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Records [tripId] as the active trip and ensures the service is running.
  static Future<void> startForTrip(int tripId) async {
    if (kIsWeb || !AppConfig.backgroundTrackingEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConfig.activeTripStorageKey, tripId);
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('refresh', {'tripId': tripId});
    } else {
      await service.startService();
    }
  }

  /// Clears the active trip and stops the service if it is running.
  static Future<void> stop() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.activeTripStorageKey);
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('stopService');
    }
  }
}

/// iOS background-fetch entry point. Sends a single fix when iOS wakes the app.
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await _reportOnce();
  return true;
}

/// Foreground-service / background entry point. Runs on its own isolate.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((_) {
    service.stopSelf();
  });

  // First fix immediately, then on a fixed cadence.
  _reportOnce();
  Timer.periodic(AppConfig.backgroundTrackingInterval, (timer) async {
    final keepGoing = await _reportOnce();
    if (!keepGoing) {
      timer.cancel();
      service.stopSelf();
    }
  });
}

final Dio _bgDio = Dio(
  BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.connectTimeout,
    headers: const {'Accept': 'application/json'},
  ),
);

/// Captures the current position and posts it for the active trip.
///
/// Returns `false` when there is no active trip so the caller can stop the
/// service; returns `true` in every other case (including transient failures)
/// so tracking keeps retrying on the next tick.
Future<bool> _reportOnce() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final tripId = prefs.getInt(AppConfig.activeTripStorageKey) ?? 0;
  if (tripId <= 0) return false;

  final position = await _currentPosition();
  if (position == null) return true;

  await _postLocation(tripId, position.latitude, position.longitude);
  return true;
}

Future<Position?> _currentPosition() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  } catch (_) {
    return null;
  }
}

Future<void> _postLocation(int tripId, double lat, double lng) async {
  try {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConfig.tokenStorageKey);
    if (token == null || token.isEmpty) return;
    await _bgDio.post<dynamic>(
      ApiEndpoints.tripLocation(tripId),
      data: {'lat': lat, 'lng': lng},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  } catch (_) {
    // Swallow transient/offline errors; the next tick retries.
  }
}
