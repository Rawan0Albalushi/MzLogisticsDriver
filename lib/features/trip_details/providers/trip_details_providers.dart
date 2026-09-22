import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/trip_status.dart';
import '../../tracking/providers/background_tracking_controller.dart';
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
  var _finishingDelivered = false;

  @override
  StatusActionState build(int arg) => const StatusActionState();

  /// Delivery confirmation already finished the driver's work. Close any trip
  /// still sitting on the internal delivered status without another button.
  Future<void> finishDelivered({bool retry = false}) async {
    if (_finishingDelivered || state.submitting) return;
    if (!retry && state.error != null) return;
    final trip = ref.read(tripDetailsProvider(arg)).valueOrNull;
    if (trip?.status != TripStatus.delivered) return;

    _finishingDelivered = true;
    state = const StatusActionState(submitting: true);
    try {
      final updated = await ref
          .read(tripsRepositoryProvider)
          .updateStatus(arg, TripStatus.completed.apiValue);
      ref.invalidate(tripDetailsProvider(arg));
      ref.invalidate(tripsListProvider);
      ref.invalidate(completedTripsProvider);
      await ref.read(backgroundTrackingProvider).syncActiveTrip(null);
      state = const StatusActionState();
      if (updated.status != TripStatus.completed) {
        _finishingDelivered = false;
      }
    } on ApiException catch (error) {
      _finishingDelivered = false;
      state = StatusActionState(
        error: error.message,
        offline: error.isOffline,
      );
    } catch (error) {
      _finishingDelivered = false;
      state = StatusActionState(error: error.toString());
    }
  }

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

  Future<Trip?> advance() async {
    state = const StatusActionState(submitting: true);
    try {
      final repo = ref.read(tripsRepositoryProvider);
      var trip = ref.read(tripDetailsProvider(arg)).valueOrNull ??
          await repo.show(arg);
      final steps = trip.status.advanceApiValues;
      if (steps.isEmpty) {
        state = const StatusActionState();
        return trip;
      }
      for (final next in steps) {
        trip = await repo.updateStatus(arg, next);
      }
      ref.invalidate(tripDetailsProvider(arg));
      ref.invalidate(tripsListProvider);
      ref.invalidate(completedTripsProvider);
      // Start sharing once the trip is active; stop once it is finished.
      await ref
          .read(backgroundTrackingProvider)
          .syncActiveTrip(trip.status.canShareLocation ? trip : null);
      state = const StatusActionState();
      return trip;
    } on ApiException catch (error) {
      state = StatusActionState(
        error: error.message,
        offline: error.isOffline,
      );
      return null;
    } catch (error) {
      state = StatusActionState(error: error.toString());
      return null;
    }
  }
}
