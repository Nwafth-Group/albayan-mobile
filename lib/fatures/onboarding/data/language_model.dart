
// ============================================
// FILE: lib/fatures/language/data/models/language_model.dart
// ============================================

class LanguageModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String code;
  final String direction;
  final bool isDefault;
  final int sortOrder;
  final String? imageUrl;

  const LanguageModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.code,
    required this.direction,
    required this.isDefault,
    required this.sortOrder,
    this.imageUrl,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    return LanguageModel(
      id:        json['id']         as String,
      nameAr:    json['name_ar']    as String,
      nameEn:    json['name_en']    as String,
      code:      json['code']       as String,
      direction: json['direction']  as String,
      isDefault: json['is_default'] == true,
      sortOrder: json['sort_order'] as int,
      imageUrl:  image?['url']      as String?,
    );
  }

  bool get isRtl => direction == 'rtl';

  /// Display name based on current locale
  String displayName(String locale) =>
      locale == 'ar' ? nameAr : nameEn;
}