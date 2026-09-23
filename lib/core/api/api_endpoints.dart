class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String activateDriver = '/auth/driver/activate';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String dashboard = '/dashboard';
  static const String trips = '/trips';
  static const String notifications = '/notifications';

  static String trip(int id) => '/trips/$id';
  static String tripStatus(int id) => '/trips/$id/status';
  static String tripLocation(int id) => '/trips/$id/location';
  static String tripPod(int id) => '/trips/$id/pod';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
}
