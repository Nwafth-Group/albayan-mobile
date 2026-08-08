
// ============================================
// FILE: lib/fatures/books/data/models/book_detail_model.dart
// ============================================

import 'package:albayan/fatures/articles/data/models/author_model.dart';
import 'package:albayan/fatures/articles/data/models/keyword_model.dart';
import 'package:albayan/fatures/authors/data/models/country_model.dart';

import 'publisher_model.dart';

/// The language-specific "version" a book was requested/opened in.
/// Holds the actual purchasable content: title, price, description, cover…
class BookVersionModel {
  final String id;
  final String language;
  final String name;
  final String? isbn;
  final num price;
  final num? finalPrice;
  final int pagesTotal;
  final int pagesFree;
  final String? description;
  final String? explanation;
  final String? cover;
  final List<String> media;

  const BookVersionModel({
    required this.id,
    required this.language,
    required this.name,
    required this.isbn,
    required this.price,
    required this.finalPrice,
    required this.pagesTotal,
    required this.pagesFree,
    required this.description,
    required this.explanation,
    required this.cover,
    required this.media,
  });

  num get effectivePrice => finalPrice ?? price;
  bool get hasDiscount => finalPrice != null && finalPrice! < price;
  bool get isFree => effectivePrice <= 0;

  factory BookVersionModel.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    final media = rawMedia is List
        ? rawMedia
            .whereType<Map<String, dynamic>>()
            .map((e) => e['url']?.toString() ?? '')
            .where((u) => u.isNotEmpty)
            .toList()
        : <String>[];
    return BookVersionModel(
      id: json['id']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isbn: json['isbn']?.toString(),
      price: json['price'] is num ? json['price'] as num : 0,
      finalPrice:
          json['final_price'] is num ? json['final_price'] as num : null,
      pagesTotal: _toInt(json['pages_total']),
      pagesFree: _toInt(json['pages_free']),
      description: json['description']?.toString(),
      explanation: json['explanation']?.toString(),
      cover: json['cover']?.toString(),
      media: media,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class BookDetailModel {
  final String id;
  final AuthorModel? author;
  final PublisherModel? publisher;
  final CountryModel? country;
  final String sku;
  final bool isNew;
  final List<KeywordModel> keywords;
  final List<KeywordModel> categories;
  final double rate;
  final int rateCount;
  final bool isFavorite;
  final bool allowedCommenting;
  final bool allowedRating;
  final List<String> languageOptions;
  final BookVersionModel version;

  const BookDetailModel({
    required this.id,
    required this.author,
    required this.publisher,
    required this.country,
    required this.sku,
    required this.isNew,
    required this.keywords,
    required this.categories,
    required this.rate,
    required this.rateCount,
    required this.isFavorite,
    required this.allowedCommenting,
    required this.allowedRating,
    required this.languageOptions,
    required this.version,
  });

  String get title => version.name;
  String? get image => version.cover;
  num get effectivePrice => version.effectivePrice;
  bool get hasDiscount => version.hasDiscount;
  bool get isFree => version.isFree;

  /// "Eng, Arb" style label from ['en','ar'].
  String get languageLabel {
    const map = {'en': 'Eng', 'ar': 'Arb', 'fr': 'Fr'};
    if (languageOptions.isEmpty) return '-';
    return languageOptions
        .map((c) => map[c.toLowerCase()] ?? c.toUpperCase())
        .join(', ');
  }

  factory BookDetailModel.fromJson(Map<String, dynamic> json) {
    final rawKeywords = json['keywords'];
    final rawCategories = json['categories'];
    final rawLangs = json['language_options'];
    return BookDetailModel(
      id: json['id']?.toString() ?? '',
      author: json['author'] is Map<String, dynamic>
          ? AuthorModel.fromJson(json['author'])
          : null,
      publisher: json['publisher'] is Map<String, dynamic>
          ? PublisherModel.fromJson(json['publisher'])
          : null,
      country: json['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(json['country'])
          : null,
      sku: json['sku']?.toString() ?? '',
      isNew: json['is_new'] == true,
      keywords: rawKeywords is List
          ? rawKeywords
              .whereType<Map<String, dynamic>>()
              .map(KeywordModel.fromJson)
              .toList()
          : const [],
      categories: rawCategories is List
          ? rawCategories
              .whereType<Map<String, dynamic>>()
              .map(KeywordModel.fromJson)
              .toList()
          : const [],
      rate: _toDouble(json['rate']),
      rateCount: _toInt(json['rate_count']),
      isFavorite: json['is_favorite'] == true,
      allowedCommenting: json['allowed_commenting'] == true,
      allowedRating: json['allowed_rating'] == true,
      languageOptions: rawLangs is List
          ? rawLangs.map((e) => e.toString()).toList()
          : const [],
      version: json['version'] is Map<String, dynamic>
          ? BookVersionModel.fromJson(json['version'])
          : const BookVersionModel(
              id: '',
              language: '',
              name: '',
              isbn: null,
              price: 0,
              finalPrice: null,
              pagesTotal: 0,
              pagesFree: 0,
              description: null,
              explanation: null,
              cover: null,
              media: [],
            ),
    );
  }

  BookDetailModel copyWith({bool? isFavorite}) {
    return BookDetailModel(
      id: id,
      author: author,
      publisher: publisher,
      country: country,
      sku: sku,
      isNew: isNew,
      keywords: keywords,
      categories: categories,
      rate: rate,
      rateCount: rateCount,
      isFavorite: isFavorite ?? this.isFavorite,
      allowedCommenting: allowedCommenting,
      allowedRating: allowedRating,
      languageOptions: languageOptions,
      version: version,
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
