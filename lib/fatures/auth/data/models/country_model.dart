
// ============================================
// FILE: lib/features/auth/data/models/country_model.dart
// ============================================

class CountryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nationalityAr;
  final String nationalityEn;
  final String phoneCode;
  final String image;

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
      id:             json['id']              as String,
      nameAr:         json['name_ar']         as String,
      nameEn:         json['name_en']         as String,
      nationalityAr:  json['nationality_ar']  as String,
      nationalityEn:  json['nationality_en']  as String,
      phoneCode:      json['phone_code']      as String,
      image:          json['image']           as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':              id,
    'name_ar':         nameAr,
    'name_en':         nameEn,
    'nationality_ar':  nationalityAr,
    'nationality_en':  nationalityEn,
    'phone_code':      phoneCode,
    'image':           image,
  };

  /// Display name based on current locale
  String displayName(String locale) =>
      locale == 'ar' ? nameAr : nameEn;
}