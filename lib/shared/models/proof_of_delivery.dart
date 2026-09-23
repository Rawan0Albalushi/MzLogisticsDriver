import '../../core/api/json_readers.dart';

class ProofOfDelivery {
  const ProofOfDelivery({
    required this.id,
    this.receiverName,
    this.otpVerified,
    this.receivedQuantity,
    this.notes,
    this.capturedAt,
  });

  final int id;
  final String? receiverName;
  final bool? otpVerified;
  final double? receivedQuantity;
  final String? notes;
  final String? capturedAt;

  factory ProofOfDelivery.fromJson(Map<String, dynamic> json) {
    return ProofOfDelivery(
      id: readInt(json['id']) ?? 0,
      receiverName: readString(json['receiver_name']),
      otpVerified: json['otp_verified'] == true,
      receivedQuantity: readDouble(json['received_quantity']),
      notes: readString(json['notes']),
      capturedAt: readString(json['captured_at']),
    );
  }
}
