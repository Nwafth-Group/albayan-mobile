
// ============================================
// FILE: lib/fatures/articles/data/models/similar_articles_response.dart
// ============================================

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

/// The `similar` payload has the same item shape as a corner's article list,
/// so we reuse [CornerArticleModel] instead of duplicating it.
class SimilarArticlesResponse {
  final List<CornerArticleModel> items;
  final PaginationMeta meta;

  const SimilarArticlesResponse({required this.items, required this.meta});

  factory SimilarArticlesResponse.fromData(Map<String, dynamic> data) {
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
    return SimilarArticlesResponse(items: items, meta: meta);
  }
}