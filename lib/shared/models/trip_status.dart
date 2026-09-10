enum TripStatus {
  unassigned,
  assigned,
  arrivedAtPickup,
  loaded,
  inTransit,
  arrived,
  delivered,
  completed,
  cancelled,
  unknown;

  static const List<TripStatus> driverFlow = [
    assigned,
    arrivedAtPickup,
    loaded,
    inTransit,
    arrived,
    delivered,
    completed,
  ];

  static const Set<TripStatus> activeStatuses = {
    assigned,
    arrivedAtPickup,
    loaded,
    inTransit,
    arrived,
    delivered,
  };

  static TripStatus fromApi(String? value) {
    return switch (value) {
      'unassigned' => unassigned,
      'assigned' => assigned,
      'arrived_at_pickup' => arrivedAtPickup,
      'loaded' => loaded,
      'in_transit' => inTransit,
      'arrived' => arrived,
      'delivered' => delivered,
      'completed' => completed,
      'cancelled' => cancelled,
      _ => unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      unassigned => 'unassigned',
      assigned => 'assigned',
      arrivedAtPickup => 'arrived_at_pickup',
      loaded => 'loaded',
      inTransit => 'in_transit',
      arrived => 'arrived',
      delivered => 'delivered',
      completed => 'completed',
      cancelled => 'cancelled',
      unknown => 'unknown',
    };
  }

  String get labelKey => 'status.$apiValue';

  String? get nextApiValue {
    return switch (this) {
      assigned => arrivedAtPickup.apiValue,
      arrivedAtPickup => loaded.apiValue,
      loaded => inTransit.apiValue,
      inTransit => arrived.apiValue,
      delivered => completed.apiValue,
      _ => null,
    };
  }

  String? get nextActionKey {
    return switch (this) {
      assigned => 'action.arrived_at_pickup',
      arrivedAtPickup => 'action.loaded',
      loaded => 'action.in_transit',
      inTransit => 'action.arrived',
      delivered => 'action.completed',
      _ => null,
    };
  }

  bool get isActive => activeStatuses.contains(this);

  bool get needsPod => this == arrived;

  bool get canShareLocation => isActive;

  int get progressIndex {
    final index = driverFlow.indexOf(this);
    return index < 0 ? 0 : index;
  }
}
