import '../../core/api/json_readers.dart';

class ProofOfDelivery {
  const ProofOfDelivery({
    required this.id,
    this.receiverName,
    this.otpVerified,
    this.receivedQuantity,
    this.notes,
    this.capturedAt,
    this.photoCount = 0,
    this.hasSignature = false,
  });

  final int id;
  final String? receiverName;
  final bool? otpVerified;
  final double? receivedQuantity;
  final String? notes;
  final String? capturedAt;
  final int photoCount;
  final bool hasSignature;

  bool get hasDocuments => photoCount > 0 || hasSignature;

  factory ProofOfDelivery.fromJson(Map<String, dynamic> json) {
    return ProofOfDelivery(
      id: readInt(json['id']) ?? 0,
      receiverName: readString(json['receiver_name']),
      otpVerified: json['otp_verified'] == true,
      receivedQuantity: readDouble(json['received_quantity']),
      notes: readString(json['notes']),
      capturedAt: readString(json['captured_at']),
      photoCount: _photoCount(json['photo_paths']),
      hasSignature: readString(json['signature_path']) != null,
    );
  }

  static int _photoCount(dynamic value) {
    if (value is List) {
      return value.length;
    }
    return 0;
  }
}
