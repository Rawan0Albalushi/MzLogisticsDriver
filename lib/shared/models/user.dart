import '../../core/api/json_readers.dart';
import 'driver_profile.dart';
import 'organization.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.locale,
    this.userType,
    this.organization,
    this.driverProfile,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? locale;
  final String? userType;
  final Organization? organization;
  final DriverProfile? driverProfile;

  bool get isDriver => userType == 'driver';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: readInt(json['id']) ?? 0,
      name: readString(json['name']) ?? '',
      email: readString(json['email']) ?? '',
      phone: readString(json['phone']),
      locale: readString(json['locale']),
      userType: readString(json['user_type']),
      organization: readMap(json['organization']) != null
          ? Organization.fromJson(readMap(json['organization'])!)
          : null,
      driverProfile: readMap(json['driver_profile']) != null
          ? DriverProfile.fromJson(readMap(json['driver_profile'])!)
          : null,
    );
  }
}
