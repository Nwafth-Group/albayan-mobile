
// ============================================
// FILE: lib/fatures/corners/data/models/corner_article_model.dart
// ============================================

class CornerArticleModel {
  final String id;
  final String title;
  final String author;
  final int issueNumber;
  final num price;
  final String? image;
  final DateTime? publishedAt;
  final double rate;
  final bool isFavorite;

  const CornerArticleModel({
    required this.id,
    required this.title,
    required this.author,
    required this.issueNumber,
    required this.price,
    required this.image,
    required this.publishedAt,
    required this.rate,
    required this.isFavorite,
  });

  bool get isFree => price <= 0;

  factory CornerArticleModel.fromJson(Map<String, dynamic> json) {
    return CornerArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      issueNumber: _toInt(json['issue_number']),
      price: (json['price'] is num) ? json['price'] as num : 0,
      image: json['image']?.toString(),
      publishedAt: _toDate(json['published_at']),
      rate: _toDouble(json['rate']),
      isFavorite: json['is_favorite'] == true,
    );
  }

  CornerArticleModel copyWith({bool? isFavorite}) {
    return CornerArticleModel(
      id: id,
      title: title,
      author: author,
      issueNumber: issueNumber,
      price: price,
      image: image,
      publishedAt: publishedAt,
      rate: rate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}