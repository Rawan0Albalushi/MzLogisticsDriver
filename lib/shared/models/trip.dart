import '../../core/api/json_readers.dart';
import 'job.dart';
import 'proof_of_delivery.dart';
import 'trip_status.dart';
import 'truck.dart';

class Trip {
  const Trip({
    required this.id,
    required this.reference,
    required this.status,
    this.sequence,
    this.plannedQuantity,
    this.deliveredQuantity,
    this.pickupAddress,
    this.pickupCity,
    this.pickupLat,
    this.pickupLng,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryLat,
    this.deliveryLng,
    this.currentLat,
    this.currentLng,
    this.etaAt,
    this.assignedAt,
    this.createdAt,
    this.otpCode,
    this.job,
    this.truck,
    this.proofOfDelivery,
  });

  final int id;
  final String reference;
  final TripStatus status;
  final int? sequence;
  final double? plannedQuantity;
  final double? deliveredQuantity;
  final String? pickupAddress;
  final String? pickupCity;
  final double? pickupLat;
  final double? pickupLng;
  final String? deliveryAddress;
  final String? deliveryCity;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? currentLat;
  final double? currentLng;
  final String? etaAt;
  final String? assignedAt;
  final String? createdAt;
  final String? otpCode;
  final TransportJob? job;
  final Truck? truck;
  final ProofOfDelivery? proofOfDelivery;

  String get pickupLabel =>
      [pickupAddress, pickupCity].whereType<String>().join(', ');

  String get deliveryLabel =>
      [deliveryAddress, deliveryCity].whereType<String>().join(', ');

  String? get tripDateRaw => assignedAt ?? createdAt;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: readInt(json['id']) ?? 0,
      reference: readString(json['reference']) ?? '',
      status: TripStatus.fromApi(readString(json['status'])),
      sequence: readInt(json['sequence']),
      plannedQuantity: readDouble(json['planned_quantity']),
      deliveredQuantity: readDouble(json['delivered_quantity']),
      pickupAddress: readString(json['pickup_address']),
      pickupCity: readString(json['pickup_city']),
      pickupLat: readDouble(json['pickup_lat']),
      pickupLng: readDouble(json['pickup_lng']),
      deliveryAddress: readString(json['delivery_address']),
      deliveryCity: readString(json['delivery_city']),
      deliveryLat: readDouble(json['delivery_lat']),
      deliveryLng: readDouble(json['delivery_lng']),
      currentLat: readDouble(json['current_lat']),
      currentLng: readDouble(json['current_lng']),
      etaAt: readString(json['eta_at']),
      assignedAt: readString(json['assigned_at']),
      createdAt: readString(json['created_at']),
      otpCode: readString(json['otp_code']),
      job: readMap(json['job']) != null
          ? TransportJob.fromJson(readMap(json['job'])!)
          : null,
      truck: readMap(json['truck']) != null
          ? Truck.fromJson(readMap(json['truck'])!)
          : null,
      proofOfDelivery: readMap(json['proof_of_delivery']) != null
          ? ProofOfDelivery.fromJson(readMap(json['proof_of_delivery'])!)
          : null,
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.tripsActive,
    required this.tripsInTransit,
  });

  final int tripsActive;
  final int tripsInTransit;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      tripsActive: readInt(json['trips_active']) ?? 0,
      tripsInTransit: readInt(json['trips_in_transit']) ?? 0,
    );
  }
}
