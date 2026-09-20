
// ============================================
// FILE: lib/fatures/library/data/models/library_article_model.dart
// ============================================

import '../../../issues/data/models/pagination_meta.dart';

class LibraryArticleModel {
  final String id;

  /// Small line above the title, e.g. "Lorem lorem , 0908".
  final String subtitle;

  final String title;
  final String author;
  final String? image;
  final double rate;
  final DateTime date;

  const LibraryArticleModel({
    required this.id,
    required this.subtitle,
    required this.title,
    required this.author,
    this.image,
    required this.rate,
    required this.date,
  });

  /// Parses one item of `GET /reader/my-library/magazine/articles`.
  factory LibraryArticleModel.fromJson(Map<String, dynamic> json) {
    final rawAuthor = json['author'];
    final rawDate = json['published_at'] ?? json['date'] ?? json['saved_at'];
    return LibraryArticleModel(
      id: json['id']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: rawAuthor is Map<String, dynamic>
          ? (rawAuthor['name']?.toString() ?? '')
          : (rawAuthor?.toString() ?? ''),
      image: (json['image'] ?? json['cover_image'] ?? json['cover'])
          ?.toString(),
      rate: (json['rate'] is num)
          ? (json['rate'] as num).toDouble()
          : double.tryParse(json['rate']?.toString() ?? '') ?? 0,
      // Falls back to now when the backend omits a date so the UI still has
      // something to render — this endpoint's item shape wasn't documented.
      date: rawDate == null
          ? DateTime.now()
          : DateTime.tryParse(rawDate.toString())?.toLocal() ?? DateTime.now(),
    );
  }
}

class LibraryArticlesResponse {
  final List<LibraryArticleModel> items;
  final PaginationMeta meta;

  const LibraryArticlesResponse({required this.items, required this.meta});

  /// Parses the `data` object: `{ "items": [...], "meta": {...} }`.
  factory LibraryArticlesResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(LibraryArticleModel.fromJson)
            .toList()
        : <LibraryArticleModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return LibraryArticlesResponse(items: items, meta: meta);
  }
}
