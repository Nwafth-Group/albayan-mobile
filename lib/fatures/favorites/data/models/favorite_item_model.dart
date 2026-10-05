
// ============================================
// FILE: lib/fatures/favorites/data/models/favorite_item_model.dart
// ============================================
//
// Parses `GET /reader/favorites?page=`:
// { "data": { "items": [ { "id", "type", "item": {...} } ], "meta": {...} } }
//
// Only a book `item` was documented; issue and article items are parsed with
// the same keys their own list endpoints use, and every field falls back
// gracefully when missing.

import '../../../issues/data/models/pagination_meta.dart';

/// What `POST /reader/favorites/toggle` accepts as `type`.
enum FavoriteType { book, issue, article }

extension FavoriteTypeApiValue on FavoriteType {
  String get apiValue {
    switch (this) {
      case FavoriteType.book:
        return 'book';
      case FavoriteType.issue:
        return 'issue';
      case FavoriteType.article:
        return 'article';
    }
  }

  static FavoriteType? fromApi(String? value) {
    switch (value) {
      case 'book':
        return FavoriteType.book;
      case 'issue':
        return FavoriteType.issue;
      case 'article':
        return FavoriteType.article;
      default:
        return null;
    }
  }
}

num? _numOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

double _double(dynamic v) => (_numOrNull(v) ?? 0).toDouble();

String? _string(dynamic v) {
  final s = v?.toString();
  return (s == null || s.trim().isEmpty) ? null : s;
}

class FavoriteItemModel {
  /// The favorite row's own id.
  final String id;
  final FavoriteType type;

  /// The favorited thing's id — what `/reader/favorites/toggle` takes and
  /// what its detail screen opens (a book's is its version id).
  final String itemId;
  final String title;
  final String? image;
  final String author;
  final num price;
  final num? finalPrice;
  final bool isFree;
  final bool isOwned;
  final double rate;
  final DateTime? publishedAt;
  final int? issueNumber;

  const FavoriteItemModel({
    required this.id,
    required this.type,
    required this.itemId,
    required this.title,
    this.image,
    this.author = '',
    this.price = 0,
    this.finalPrice,
    this.isFree = false,
    this.isOwned = false,
    this.rate = 0,
    this.publishedAt,
    this.issueNumber,
  });

  num get effectivePrice => finalPrice ?? price;
  bool get hasDiscount => finalPrice != null && finalPrice! < price;

  /// Returns null for an unknown `type` or a row without an item id, since
  /// neither can be shown or toggled.
  static FavoriteItemModel? fromJson(Map<String, dynamic> json) {
    final type = FavoriteTypeApiValue.fromApi(json['type']?.toString());
    final item = json['item'];
    if (type == null || item is! Map<String, dynamic>) return null;
    final itemId = item['id']?.toString() ?? '';
    if (itemId.isEmpty) return null;

    // `author` is a plain name on books but may be an object elsewhere.
    final rawAuthor = item['author'];
    final author = rawAuthor is Map
        ? [_string(rawAuthor['title']), _string(rawAuthor['name'])]
            .whereType<String>()
            .join(' ')
        : (_string(rawAuthor) ?? '');

    final price = _numOrNull(item['price']) ?? 0;
    final finalPrice = _numOrNull(item['final_price']);
    final issueNumber = _numOrNull(item['issue_number'])?.toInt();

    return FavoriteItemModel(
      id: json['id']?.toString() ?? '',
      type: type,
      itemId: itemId,
      title: _string(item['name']) ?? _string(item['title']) ?? '',
      image: _string(item['image']) ??
          _string(item['cover_image']) ??
          _string(item['cover']),
      author: author,
      price: price,
      finalPrice: finalPrice,
      isFree: item['is_free'] == true || (finalPrice ?? price) <= 0,
      isOwned: item['is_owned'] == true,
      rate: _double(item['rate']),
      publishedAt: item['published_at'] == null
          ? null
          : DateTime.tryParse(item['published_at'].toString())?.toLocal(),
      issueNumber: issueNumber,
    );
  }
}

class FavoritesResponse {
  final List<FavoriteItemModel> items;
  final PaginationMeta meta;

  const FavoritesResponse({required this.items, required this.meta});

  factory FavoritesResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final rawMeta = data['meta'];
    return FavoritesResponse(
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(FavoriteItemModel.fromJson)
              .whereType<FavoriteItemModel>()
              .toList()
          : const [],
      meta: rawMeta is Map<String, dynamic>
          ? PaginationMeta.fromJson(rawMeta)
          : PaginationMeta.empty,
    );
  }
}
