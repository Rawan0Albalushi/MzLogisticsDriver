import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/json_readers.dart';
import '../../../shared/models/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(apiClientProvider));
});

class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  Future<List<AppNotification>> list() async {
    final envelope = await _client.get<List<AppNotification>>(
      ApiEndpoints.notifications,
      query: const {'per_page': 40},
      parse: (raw) {
        if (raw is List) {
          return readMapList(raw).map(AppNotification.fromJson).toList();
        }
        final map = readMap(raw);
        return readMapList(map?['data']).map(AppNotification.fromJson).toList();
      },
    );
    return envelope.data;
  }

  Future<void> markRead(String id) {
    return _client.post<void>(
      ApiEndpoints.markNotificationRead(id),
      parse: (_) {},
    );
  }

  Future<void> markAllRead() {
    return _client.post<void>(
      ApiEndpoints.markAllNotificationsRead,
      parse: (_) {},
    );
  }
}
