// ============================================
// FILE: lib/fatures/settings/data/models/company_info_model.dart
// ============================================
//
// Parses `GET /public/company-info` → `data`.

String? _s(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

class CompanyInfoModel {
  final String? nameAr;
  final String? nameEn;
  final String? mobile;
  final String? landline;
  final String? whatsapp;
  final String? email;
  final String? website;
  final String? googlePlayUrl;
  final String? appStoreUrl;
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? linkedin;
  final num? vatPercentage;
  final String? vatNumber;
  final String? address;

  /// `gift_message_template` by language code ('ar' / 'en'), with
  /// `{sender_name}`, `{item_name}`, `{gift_code}`, `{google_play_url}` and
  /// `{app_store_url}` placeholders — for the gift flow.
  final Map<String, String> giftMessageTemplates;

  const CompanyInfoModel({
    this.nameAr,
    this.nameEn,
    this.mobile,
    this.landline,
    this.whatsapp,
    this.email,
    this.website,
    this.googlePlayUrl,
    this.appStoreUrl,
    this.facebook,
    this.instagram,
    this.twitter,
    this.linkedin,
    this.vatPercentage,
    this.vatNumber,
    this.address,
    this.giftMessageTemplates = const {},
  });

  /// The company name in [languageCode], falling back to the other one.
  String? name(String languageCode) =>
      languageCode == 'ar' ? (nameAr ?? nameEn) : (nameEn ?? nameAr);

  /// The number to call: mobile first, then landline.
  String? get phone => mobile ?? landline;

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    final templates = <String, String>{};
    final raw = json['gift_message_template'];
    if (raw is Map) {
      raw.forEach((k, v) {
        final text = _s(v);
        if (text != null) templates[k.toString()] = text;
      });
    }
    // Flat fallbacks, used only if the map is missing a language.
    templates.putIfAbsent(
      'ar',
      () => _s(json['gift_message_template_ar']) ?? '',
    );
    templates.putIfAbsent(
      'en',
      () => _s(json['gift_message_template_en']) ?? '',
    );
    templates.removeWhere((_, v) => v.isEmpty);

    final vat = json['vat_percentage'];
    return CompanyInfoModel(
      nameAr: _s(json['name_ar']),
      nameEn: _s(json['name_en']),
      mobile: _s(json['mobile']),
      landline: _s(json['landline']),
      whatsapp: _s(json['whatsapp']),
      email: _s(json['email']),
      website: _s(json['website']),
      googlePlayUrl: _s(json['google_play_url']),
      appStoreUrl: _s(json['app_store_url']),
      facebook: _s(json['facebook']),
      instagram: _s(json['instagram']),
      twitter: _s(json['twitter']),
      linkedin: _s(json['linkedin']),
      vatPercentage: vat is num ? vat : num.tryParse(vat?.toString() ?? ''),
      vatNumber: _s(json['vat_number']),
      address: _s(json['address']),
      giftMessageTemplates: templates,
    );
  }
}

/// `subject` values `POST /public/contact-us` accepts.
enum ContactSubject { inquiry, complaint, feedback, support }

extension ContactSubjectApiValue on ContactSubject {
  String get apiValue =>
      name; // 'inquiry' | 'complaint' | 'feedback' | 'support'
}
