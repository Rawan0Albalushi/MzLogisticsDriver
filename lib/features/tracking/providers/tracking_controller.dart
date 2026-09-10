import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../trips/data/trips_repository.dart';
import '../data/location_service.dart';

enum TrackingUiStatus {
  idle,
  sharing,
  shared,
  offline,
  failed,
}

class TrackingState {
  const TrackingState({
    required this.issue,
    required this.ui,
    this.lastLat,
    this.lastLng,
  });

  final LocationIssue issue;
  final TrackingUiStatus ui;
  final double? lastLat;
  final double? lastLng;

  TrackingState copyWith({
    LocationIssue? issue,
    TrackingUiStatus? ui,
    double? lastLat,
    double? lastLng,
  }) {
    return TrackingState(
      issue: issue ?? this.issue,
      ui: ui ?? this.ui,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
    );
  }
}

final trackingControllerProvider = AutoDisposeNotifierProviderFamily<
    TrackingController, TrackingState, int>(TrackingController.new);

class TrackingController extends AutoDisposeFamilyNotifier<TrackingState, int> {
  @override
  TrackingState build(int arg) {
    _inspect();
    return const TrackingState(
      issue: LocationIssue.ready,
      ui: TrackingUiStatus.idle,
    );
  }

  Future<void> _inspect() async {
    try {
      final issue = await ref.read(locationServiceProvider).inspect();
      state = state.copyWith(issue: issue);
    } catch (_) {
      // Provider may already be disposed.
    }
  }

  Future<void> share() async {
    state = state.copyWith(ui: TrackingUiStatus.sharing);
    final check = await ref.read(locationServiceProvider).currentFix();
    if (check.issue != LocationIssue.ready || check.fix == null) {
      state = state.copyWith(
        issue: check.issue,
        ui: TrackingUiStatus.failed,
      );
      return;
    }

    try {
      await ref.read(tripsRepositoryProvider).shareLocation(
            id: arg,
            lat: check.fix!.lat,
            lng: check.fix!.lng,
          );
      state = state.copyWith(
        issue: LocationIssue.ready,
        ui: TrackingUiStatus.shared,
        lastLat: check.fix!.lat,
        lastLng: check.fix!.lng,
      );
    } on ApiException catch (error) {
      state = state.copyWith(
        ui: error.isOffline ? TrackingUiStatus.offline : TrackingUiStatus.failed,
      );
    } catch (_) {
      state = state.copyWith(ui: TrackingUiStatus.failed);
    }
  }
}
