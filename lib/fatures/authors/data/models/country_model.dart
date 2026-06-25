
// ============================================
// FILE: lib/fatures/authors/data/models/country_model.dart
// ============================================

class CountryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nationalityAr;
  final String nationalityEn;
  final String? phoneCode;
  final String? image;

  const CountryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nationalityAr,
    required this.nationalityEn,
    required this.phoneCode,
    required this.image,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nationalityAr: json['nationality_ar']?.toString() ?? '',
      nationalityEn: json['nationality_en']?.toString() ?? '',
      phoneCode: json['phone_code']?.toString(),
      image: json['image']?.toString(),
    );
  }
}