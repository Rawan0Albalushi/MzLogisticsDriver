import '../../core/api/json_readers.dart';

class Truck {
  const Truck({
    required this.id,
    this.plateNumber,
    this.type,
    this.capacityTons,
    this.make,
    this.model,
  });

  final int id;
  final String? plateNumber;
  final String? type;
  final double? capacityTons;
  final String? make;
  final String? model;

  String get label {
    final parts = <String>[
      ?plateNumber,
      if (make != null || model != null) [make, model].whereType<String>().join(' '),
    ];
    return parts.join(' · ');
  }

  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      id: readInt(json['id']) ?? 0,
      plateNumber: readString(json['plate_number']),
      type: readString(json['type']),
      capacityTons: readDouble(json['capacity_tons']),
      make: readString(json['make']),
      model: readString(json['model']),
    );
  }
}
