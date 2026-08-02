
// ============================================
// FILE: lib/fatures/articles/data/models/articles_list_response.dart
// ============================================

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

class ArticlesListResponse {
  final List<CornerArticleModel> items;
  final PaginationMeta meta;

  const ArticlesListResponse({
    required this.items,
    required this.meta,
  });

  /// Parses the `data` object (which contains `items` + `meta`).
  factory ArticlesListResponse.fromData(Map<String, dynamic> data) {
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

    return ArticlesListResponse(items: items, meta: meta);
  }
}
