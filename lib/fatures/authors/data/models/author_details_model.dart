
// ============================================
// FILE: lib/fatures/authors/data/models/author_details_model.dart
// ============================================

import 'country_model.dart';

class AuthorDetailsModel {
  final String id;
  final String? image;
  final String type;
  final String name;
  final String? nickname;
  final CountryModel? country;
  final String? biography;
  final String? shortBio;
  final Map<String, String> socialLinks;

  const AuthorDetailsModel({
    required this.id,
    required this.image,
    required this.type,
    required this.name,
    required this.nickname,
    required this.country,
    required this.biography,
    required this.shortBio,
    required this.socialLinks,
  });

  factory AuthorDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawSocial = json['social_links'];
    final social = <String, String>{};
    if (rawSocial is Map) {
      rawSocial.forEach((k, v) {
        if (v != null && v.toString().trim().isNotEmpty) {
          social[k.toString()] = v.toString();
        }
      });
    }
    return AuthorDetailsModel(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString(),
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      country: json['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(json['country'])
          : null,
      biography: json['biography']?.toString(),
      shortBio: json['short_bio']?.toString(),
      socialLinks: social,
    );
  }
}