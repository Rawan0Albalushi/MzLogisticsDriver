class AppConfig {
  const AppConfig._();

  static const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');
  static const String devLanHost = String.fromEnvironment('DEV_LAN_HOST');
  static const int apiPort = 8000;

  /// Optional PC Wi-Fi IPv4 for a physical phone on the same network.
  /// USB debugging does not need this: run `adb reverse tcp:8000 tcp:8000`.
  static String get apiHost {
    if (_apiBaseUrlFromEnv.isNotEmpty) {
      return Uri.parse(_apiBaseUrlFromEnv).host;
    }
    if (devLanHost.isNotEmpty) return devLanHost;
    return '192.168.100.197';
  }

  static String get apiBaseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
    return 'http://$apiHost:$apiPort/api/v1';
  }

  static const String demoEmail = 'driver@omanhaulers.om';
  static const String demoPassword = 'Password123!';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const String tokenStorageKey = 'mz_driver_token';
  static const String localeStorageKey = 'mz_driver_locale';

  /// Temporarily hidden until live tracking is ready to ship.
  static const bool liveTrackingEnabled = false;
}
