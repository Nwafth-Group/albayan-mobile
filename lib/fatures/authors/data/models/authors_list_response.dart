
// ============================================
// FILE: lib/fatures/authors/data/models/authors_list_response.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

import 'author_list_model.dart';

class AuthorsListResponse {
  final List<AuthorListModel> items;
  final PaginationMeta meta;

  const AuthorsListResponse({
    required this.items,
    required this.meta,
  });

  /// Parses the `data` object (which contains `items` + `meta`).
  factory AuthorsListResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(AuthorListModel.fromJson)
            .toList()
        : <AuthorListModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return AuthorsListResponse(items: items, meta: meta);
  }
}
