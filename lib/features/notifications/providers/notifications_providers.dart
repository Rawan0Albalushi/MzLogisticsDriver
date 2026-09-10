import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_notification.dart';
import '../data/notifications_repository.dart';

final notificationsListProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) {
  return ref.watch(notificationsRepositoryProvider).list();
});
