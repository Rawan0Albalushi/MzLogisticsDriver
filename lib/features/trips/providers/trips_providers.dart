import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/trip.dart';
import '../../../shared/models/trip_status.dart';
import '../data/trips_repository.dart';

final tripsListProvider = FutureProvider.autoDispose<List<Trip>>((ref) {
  return ref.watch(tripsRepositoryProvider).list();
});

final completedTripsProvider = FutureProvider.autoDispose<List<Trip>>((ref) {
  return ref.watch(tripsRepositoryProvider).list(status: TripStatus.completed.apiValue);
});

final dashboardProvider = FutureProvider.autoDispose<DashboardSummary>((ref) {
  return ref.watch(tripsRepositoryProvider).dashboard();
});

class HomeTrips {
  const HomeTrips({
    required this.current,
    required this.assigned,
    required this.activeCount,
  });

  final Trip? current;
  final List<Trip> assigned;
  final int activeCount;
}

HomeTrips splitHomeTrips(List<Trip> trips, {int? dashboardActive}) {
  final active = trips.where((trip) => trip.status.isActive).toList();
  active.sort((a, b) => b.status.progressIndex.compareTo(a.status.progressIndex));
  final current = active.isEmpty ? null : active.first;
  final assigned = trips
      .where((trip) => trip.status == TripStatus.assigned && trip.id != current?.id)
      .toList();
  return HomeTrips(
    current: current,
    assigned: assigned,
    activeCount: dashboardActive ?? active.length,
  );
}
