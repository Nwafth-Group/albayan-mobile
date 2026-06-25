
// ============================================
// FILE: lib/fatures/corners/data/models/corner_articles_response.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

import 'corner_article_model.dart';

class CornerArticlesResponse {
  final List<CornerArticleModel> items;
  final PaginationMeta meta;

  const CornerArticlesResponse({
    required this.items,
    required this.meta,
  });

  /// Parses the `data` object (which contains `items` + `meta`).
  factory CornerArticlesResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
        .whereType<Map<String, dynamic>>()
        .map(CornerArticleModel.fromJson)
        .toList()
        : <CornerArticleModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return CornerArticlesResponse(items: items, meta: meta);
  }
}