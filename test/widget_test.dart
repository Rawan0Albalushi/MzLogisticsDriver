import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_driver_app/shared/models/trip_status.dart';

void main() {
  test('driver trip flow only allows the next status', () {
    expect(TripStatus.assigned.nextApiValue, 'arrived_at_pickup');
    expect(TripStatus.arrivedAtPickup.nextApiValue, 'loaded');
    expect(TripStatus.loaded.nextApiValue, 'in_transit');
    expect(TripStatus.inTransit.nextApiValue, 'arrived');
    expect(TripStatus.arrived.nextApiValue, isNull);
    expect(TripStatus.arrived.needsPod, isTrue);
    expect(TripStatus.delivered.nextApiValue, 'completed');
    expect(TripStatus.completed.nextApiValue, isNull);
    expect(TripStatus.cancelled.nextApiValue, isNull);
  });

  test('trip status maps to API values', () {
    expect(TripStatus.fromApi('arrived_at_pickup'), TripStatus.arrivedAtPickup);
    expect(TripStatus.inTransit.apiValue, 'in_transit');
  });
}
