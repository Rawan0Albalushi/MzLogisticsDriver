import '../../core/api/json_readers.dart';

class DriverProfile {
  const DriverProfile({
    this.licenseNumber,
    this.licenseExpiresAt,
    this.status,
  });

  final String? licenseNumber;
  final String? licenseExpiresAt;
  final String? status;

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      licenseNumber: readString(json['license_number']),
      licenseExpiresAt: readString(json['license_expires_at']),
      status: readString(json['status']),
    );
  }
}
