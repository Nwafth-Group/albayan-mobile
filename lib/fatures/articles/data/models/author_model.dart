
// ============================================
// FILE: lib/fatures/articles/data/models/author_model.dart
// ============================================

class AuthorModel {
  final String id;
  final String title;
  final String name;
  final String? image;

  const AuthorModel({
    required this.id,
    required this.title,
    required this.name,
    required this.image,
  });

  /// "Dr. Ahmed Al-Faisal"
  String get displayName =>
      title.trim().isEmpty ? name : '${title.trim()} $name';

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}