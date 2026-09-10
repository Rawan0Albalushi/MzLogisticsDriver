import '../../core/api/json_readers.dart';

class Organization {
  const Organization({
    required this.id,
    required this.name,
    this.nameAr,
    this.phone,
    this.city,
  });

  final int id;
  final String name;
  final String? nameAr;
  final String? phone;
  final String? city;

  String displayName(String languageCode) {
    if (languageCode == 'ar' && (nameAr?.isNotEmpty ?? false)) {
      return nameAr!;
    }
    return name;
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: readInt(json['id']) ?? 0,
      name: readString(json['name']) ?? '',
      nameAr: readString(json['name_ar']),
      phone: readString(json['phone']),
      city: readString(json['city']),
    );
  }
}
