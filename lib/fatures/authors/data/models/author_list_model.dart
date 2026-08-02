
// ============================================
// FILE: lib/fatures/authors/data/models/author_list_model.dart
// ============================================

class AuthorListModel {
  final String id;
  final String? image;
  final String name;
  final String? nickname;
  final String type;
  final int booksCount;
  final int articlesCount;

  const AuthorListModel({
    required this.id,
    required this.image,
    required this.name,
    required this.nickname,
    required this.type,
    required this.booksCount,
    required this.articlesCount,
  });

  factory AuthorListModel.fromJson(Map<String, dynamic> json) {
    return AuthorListModel(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString(),
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      type: json['type']?.toString() ?? '',
      booksCount: _toInt(json['books_count']),
      articlesCount: _toInt(json['articles_count']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
