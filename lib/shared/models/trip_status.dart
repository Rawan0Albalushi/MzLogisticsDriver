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

  /// Driver-facing stages. Internal API statuses collapse into these four.
  static const List<TripStatus> visibleFlow = [
    assigned,
    loaded,
    inTransit,
    delivered,
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

  TripStatus get displayStage {
    return switch (this) {
      loaded => loaded,
      inTransit || arrived => inTransit,
      delivered || completed => delivered,
      cancelled => cancelled,
      _ => assigned,
    };
  }

  String get labelKey => 'status.${displayStage.apiValue}';

  /// Sequential API values needed to reach the next visible stage.
  List<String> get advanceApiValues {
    return switch (this) {
      assigned => [arrivedAtPickup.apiValue, loaded.apiValue],
      arrivedAtPickup => [loaded.apiValue],
      loaded => [inTransit.apiValue],
      inTransit => [arrived.apiValue],
      delivered => [completed.apiValue],
      _ => const [],
    };
  }

  String? get nextActionKey {
    return switch (this) {
      assigned || arrivedAtPickup => 'action.loaded',
      loaded => 'action.in_transit',
      inTransit => 'action.record_pod',
      delivered => 'action.completed',
      _ => null,
    };
  }

  bool get isActive => activeStatuses.contains(this);

  bool get needsPod => this == arrived;

  bool get canShareLocation => isActive;

  int get progressIndex {
    final index = visibleFlow.indexOf(displayStage);
    return index < 0 ? 0 : index;
  }
}
