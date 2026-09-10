import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

enum LocationIssue {
  ready,
  serviceDisabled,
  denied,
  deniedForever,
  failed,
}

class LocationFix {
  const LocationFix({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

class LocationCheck {
  const LocationCheck(this.issue, {this.fix});

  final LocationIssue issue;
  final LocationFix? fix;
}

class LocationService {
  bool _askedThisSession = false;

  Future<LocationCheck> currentFix({bool requestIfNeeded = true}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationCheck(LocationIssue.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return const LocationCheck(LocationIssue.deniedForever);
      }

      if (permission == LocationPermission.denied) {
        if (!requestIfNeeded || _askedThisSession) {
          return const LocationCheck(LocationIssue.denied);
        }
        _askedThisSession = true;
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationCheck(LocationIssue.denied);
        }
        if (permission == LocationPermission.deniedForever) {
          return const LocationCheck(LocationIssue.deniedForever);
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationCheck(
        LocationIssue.ready,
        fix: LocationFix(lat: position.latitude, lng: position.longitude),
      );
    } catch (_) {
      return const LocationCheck(LocationIssue.failed);
    }
  }

  Future<LocationIssue> inspect() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return LocationIssue.serviceDisabled;
    }
    final permission = await Geolocator.checkPermission();
    return switch (permission) {
      LocationPermission.deniedForever => LocationIssue.deniedForever,
      LocationPermission.denied => LocationIssue.denied,
      _ => LocationIssue.ready,
    };
  }

  Future<bool> openSettings() {
    return Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }
}
