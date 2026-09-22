import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_driver_app/shared/models/trip_status.dart';

void main() {
  test('driver UI keeps only the four basic stages', () {
    expect(TripStatus.visibleFlow, [
      TripStatus.assigned,
      TripStatus.loaded,
      TripStatus.inTransit,
      TripStatus.delivered,
    ]);
  });

  test('internal statuses collapse onto the basic stages', () {
    expect(TripStatus.unassigned.displayStage, TripStatus.assigned);
    expect(TripStatus.assigned.displayStage, TripStatus.assigned);
    expect(TripStatus.arrivedAtPickup.displayStage, TripStatus.assigned);
    expect(TripStatus.loaded.displayStage, TripStatus.loaded);
    expect(TripStatus.inTransit.displayStage, TripStatus.inTransit);
    expect(TripStatus.arrived.displayStage, TripStatus.inTransit);
    expect(TripStatus.delivered.displayStage, TripStatus.delivered);
    expect(TripStatus.completed.displayStage, TripStatus.delivered);
    expect(TripStatus.cancelled.displayStage, TripStatus.cancelled);
  });

  test('driver advances skip hidden statuses in one action', () {
    expect(TripStatus.assigned.advanceApiValues, [
      'arrived_at_pickup',
      'loaded',
    ]);
    expect(TripStatus.arrivedAtPickup.advanceApiValues, ['loaded']);
    expect(TripStatus.loaded.advanceApiValues, ['in_transit']);
    expect(TripStatus.inTransit.advanceApiValues, ['arrived']);
    expect(TripStatus.arrived.advanceApiValues, isEmpty);
    expect(TripStatus.arrived.needsPod, isTrue);
    expect(TripStatus.delivered.nextActionKey, isNull);
    expect(TripStatus.delivered.advanceApiValues, isEmpty);
    expect(TripStatus.completed.advanceApiValues, isEmpty);
    expect(TripStatus.cancelled.advanceApiValues, isEmpty);
  });

  test('trip status maps to API values', () {
    expect(TripStatus.fromApi('arrived_at_pickup'), TripStatus.arrivedAtPickup);
    expect(TripStatus.inTransit.apiValue, 'in_transit');
    expect(TripStatus.assigned.apiValue, 'assigned');
  });
}
