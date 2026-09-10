class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String demoEmail = 'driver@omanhaulers.om';
  static const String demoPassword = 'Password123!';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const String tokenStorageKey = 'mz_driver_token';
  static const String localeStorageKey = 'mz_driver_locale';
}
