import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/models/trip.dart';
import '../../trips/data/trips_repository.dart';
import '../../trips/providers/trips_providers.dart';

final tripDetailsProvider =
    FutureProvider.autoDispose.family<Trip, int>((ref, id) {
  return ref.watch(tripsRepositoryProvider).show(id);
});

class StatusActionState {
  const StatusActionState({
    this.submitting = false,
    this.error,
    this.offline = false,
  });

  final bool submitting;
  final String? error;
  final bool offline;
}

final statusActionProvider = AutoDisposeNotifierProviderFamily<
    StatusActionController, StatusActionState, int>(StatusActionController.new);

class StatusActionController
    extends AutoDisposeFamilyNotifier<StatusActionState, int> {
  @override
  StatusActionState build(int arg) => const StatusActionState();

  Future<bool> updateTo(String status) async {
    state = const StatusActionState(submitting: true);
    try {
      await ref.read(tripsRepositoryProvider).updateStatus(arg, status);
      ref.invalidate(tripDetailsProvider(arg));
      ref.invalidate(tripsListProvider);
      ref.invalidate(completedTripsProvider);
      state = const StatusActionState();
      return true;
    } on ApiException catch (error) {
      state = StatusActionState(
        error: error.message,
        offline: error.isOffline,
      );
      return false;
    } catch (error) {
      state = StatusActionState(error: error.toString());
      return false;
    }
  }
}
