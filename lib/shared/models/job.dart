import '../../core/api/json_readers.dart';
import 'organization.dart';
import 'shipment.dart';

class TransportJob {
  const TransportJob({
    required this.id,
    this.reference,
    this.status,
    this.totalQuantity,
    this.deliveredQuantity,
    this.customer,
    this.provider,
    this.shipment,
  });

  final int id;
  final String? reference;
  final String? status;
  final double? totalQuantity;
  final double? deliveredQuantity;
  final Organization? customer;
  final Organization? provider;
  final Shipment? shipment;

  factory TransportJob.fromJson(Map<String, dynamic> json) {
    return TransportJob(
      id: readInt(json['id']) ?? 0,
      reference: readString(json['reference']),
      status: readString(json['status']),
      totalQuantity: readDouble(json['total_quantity']),
      deliveredQuantity: readDouble(json['delivered_quantity']),
      customer: readMap(json['customer']) != null
          ? Organization.fromJson(readMap(json['customer'])!)
          : null,
      provider: readMap(json['provider']) != null
          ? Organization.fromJson(readMap(json['provider'])!)
          : null,
      shipment: readMap(json['shipment']) != null
          ? Shipment.fromJson(readMap(json['shipment'])!)
          : null,
    );
  }
}
