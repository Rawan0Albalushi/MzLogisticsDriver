import '../../core/api/json_readers.dart';

class Shipment {
  const Shipment({
    required this.id,
    this.reference,
    this.cargoType,
    this.cargoDescription,
    this.weightTons,
    this.volumeCbm,
    this.quantity,
    this.quantityUnit,
    this.notes,
  });

  final int id;
  final String? reference;
  final String? cargoType;
  final String? cargoDescription;
  final double? weightTons;
  final double? volumeCbm;
  final double? quantity;
  final String? quantityUnit;
  final String? notes;

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: readInt(json['id']) ?? 0,
      reference: readString(json['reference']),
      cargoType: readString(json['cargo_type']),
      cargoDescription: readString(json['cargo_description']),
      weightTons: readDouble(json['weight_tons']),
      volumeCbm: readDouble(json['volume_cbm']),
      quantity: readDouble(json['quantity']),
      quantityUnit: readString(json['quantity_unit']),
      notes: readString(json['notes']),
    );
  }
}
