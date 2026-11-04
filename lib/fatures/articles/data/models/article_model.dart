
// ============================================
// FILE: lib/fatures/articles/data/models/article_model.dart
// ============================================

import 'author_model.dart';
import 'keyword_model.dart';

/// Lightweight reference to the corner an article belongs to.
class ArticleCornerRef {
  final String id;
  final String name;
  final String? image;
  final String? header;

  const ArticleCornerRef({
    required this.id,
    required this.name,
    required this.image,
    required this.header,
  });

  factory ArticleCornerRef.fromJson(Map<String, dynamic> json) {
    return ArticleCornerRef(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      header: json['header']?.toString(),
    );
  }
}

class ArticleModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? summary;
  final String? url;
  final String? image;
  final AuthorModel? author;
  final ArticleCornerRef? corner;
  final int issueNumber;
  final DateTime? publishedAt;
  final num price;
  final num? finalPrice;

  /// `is_free` — the backend marks the article free regardless of price.
  final bool freeFlag;
  final double rate;
  final int rateCount;
  final bool isFavorite;

  /// `is_owned` — already in the reader's library.
  final bool isOwned;
  final bool allowedRating;
  final bool allowedCommenting;
  final List<KeywordModel> keywords;
  final List<String> languageOptions;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.url,
    required this.image,
    required this.author,
    required this.corner,
    required this.issueNumber,
    required this.publishedAt,
    required this.price,
    this.finalPrice,
    this.freeFlag = false,
    required this.rate,
    required this.rateCount,
    required this.isFavorite,
    this.isOwned = false,
    required this.allowedRating,
    required this.allowedCommenting,
    required this.keywords,
    required this.languageOptions,
  });

  /// Price the user actually pays.
  num get effectivePrice => finalPrice ?? price;

  bool get isFree => freeFlag || effectivePrice <= 0;

  /// "Eng, Arb" style label from ['en','ar'].
  String get languageLabel {
    const map = {
      'en': 'Eng',
      'ar': 'Arb',
      'fr': 'Fr',
    };
    if (languageOptions.isEmpty) return '-';
    return languageOptions
        .map((c) => map[c.toLowerCase()] ?? c.toUpperCase())
        .join(', ');
  }

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final rawKeywords = json['keywords'];
    final rawLangs = json['language_options'];
    return ArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      summary: json['summary']?.toString(),
      url: json['url']?.toString(),
      image: json['image']?.toString(),
      author: json['author'] is Map<String, dynamic>
          ? AuthorModel.fromJson(json['author'])
          : null,
      corner: json['corner'] is Map<String, dynamic>
          ? ArticleCornerRef.fromJson(json['corner'])
          : null,
      issueNumber: _toInt(json['issue_number']),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.tryParse(json['published_at'].toString()),
      price: json['price'] is num ? json['price'] as num : 0,
      finalPrice:
          json['final_price'] is num ? json['final_price'] as num : null,
      freeFlag: json['is_free'] == true,
      rate: _toDouble(json['rate']),
      rateCount: _toInt(json['rate_count']),
      isFavorite: json['is_favorite'] == true,
      // Owned, or (free) added to My Library.
      isOwned: json['is_owned'] == true ||
          json['is_in_library'] == true ||
          json['in_library'] == true ||
          json['in_my_library'] == true,
      allowedRating: json['allowed_rating'] == true,
      allowedCommenting: json['allowed_commenting'] == true,
      keywords: rawKeywords is List
          ? rawKeywords
          .whereType<Map<String, dynamic>>()
          .map(KeywordModel.fromJson)
          .toList()
          : const [],
      languageOptions:
      rawLangs is List ? rawLangs.map((e) => e.toString()).toList() : const [],
    );
  }

  ArticleModel copyWith({bool? isFavorite, bool? isOwned}) {
    return ArticleModel(
      id: id,
      title: title,
      subtitle: subtitle,
      summary: summary,
      url: url,
      image: image,
      author: author,
      corner: corner,
      issueNumber: issueNumber,
      publishedAt: publishedAt,
      price: price,
      finalPrice: finalPrice,
      freeFlag: freeFlag,
      rate: rate,
      rateCount: rateCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isOwned: isOwned ?? this.isOwned,
      allowedRating: allowedRating,
      allowedCommenting: allowedCommenting,
      keywords: keywords,
      languageOptions: languageOptions,
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
}