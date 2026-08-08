
// ============================================
// FILE: lib/fatures/publishers/data/models/publisher_detail_model.dart
// ============================================

import 'package:albayan/fatures/authors/data/models/country_model.dart';

class PublisherDetailModel {
  final String id;
  final String name;
  final String? logo;
  final String? mobile;
  final String? email;
  final CountryModel? country;
  final String? description;
  final int booksCount;
  final Map<String, String> socialLinks;

  const PublisherDetailModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.mobile,
    required this.email,
    required this.country,
    required this.description,
    required this.booksCount,
    required this.socialLinks,
  });

  factory PublisherDetailModel.fromJson(Map<String, dynamic> json) {
    final rawSocial = json['social_links'];
    final social = <String, String>{};
    if (rawSocial is Map) {
      rawSocial.forEach((k, v) {
        if (v != null && v.toString().trim().isNotEmpty) {
          social[k.toString()] = v.toString();
        }
      });
    }
    return PublisherDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      country: json['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(json['country'])
          : null,
      description: json['description']?.toString(),
      booksCount: _toInt(json['books_count']),
      socialLinks: social,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
