
// ============================================
// FILE: lib/fatures/authors/data/models/author_articles_response.dart
// ============================================

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

/// Author articles reuse the corner article item shape. The top-level
/// `params` block carries the available archive years and the selected year.
class AuthorArticlesResponse {
  final List<CornerArticleModel> items;
  final PaginationMeta meta;
  final List<int> years;
  final int? selectedYear;

  const AuthorArticlesResponse({
    required this.items,
    required this.meta,
    required this.years,
    required this.selectedYear,
  });

  /// Pass the FULL response map (contains `data` and `params`).
  factory AuthorArticlesResponse.fromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final params = response['params'];

    final rawItems = (data is Map<String, dynamic>) ? data['items'] : null;
    final items = (rawItems is List)
        ? rawItems
        .whereType<Map<String, dynamic>>()
        .map(CornerArticleModel.fromJson)
        .toList()
        : <CornerArticleModel>[];

    final rawMeta = (data is Map<String, dynamic>) ? data['meta'] : null;
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    final years = <int>[];
    int? selected;
    if (params is Map<String, dynamic>) {
      final archive = params['archive'];
      if (archive is List) {
        for (final y in archive) {
          final v = int.tryParse(y.toString());
          if (v != null) years.add(v);
        }
      }
      selected = int.tryParse(params['year']?.toString() ?? '');
    }

    return AuthorArticlesResponse(
      items: items,
      meta: meta,
      years: years,
      selectedYear: selected,
    );
  }
}