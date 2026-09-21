
// ============================================
// FILE: lib/fatures/search/data/models/keywords_list_response.dart
// ============================================

import 'package:albayan/fatures/articles/data/models/keyword_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

class KeywordsListResponse {
  final List<KeywordModel> items;
  final PaginationMeta meta;

  const KeywordsListResponse({required this.items, required this.meta});

  /// Parses the `data` object: `{ "items": [...], "meta": {...} }`.
  factory KeywordsListResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(KeywordModel.fromJson)
            .toList()
        : <KeywordModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return KeywordsListResponse(items: items, meta: meta);
  }
}
