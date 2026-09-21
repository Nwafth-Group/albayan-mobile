
// ============================================
// FILE: lib/fatures/search/data/models/search_results_response.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

import 'search_result_item_model.dart';

class SearchResultsResponse {
  final List<SearchResultItemModel> items;
  final PaginationMeta meta;
  final String activeTab;
  final SearchResultCounts counts;

  const SearchResultsResponse({
    required this.items,
    required this.meta,
    required this.activeTab,
    required this.counts,
  });

  /// Parses the `data` object of `GET /public/search`.
  factory SearchResultsResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(SearchResultItemModel.fromJson)
            .toList()
        : <SearchResultItemModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    final rawCounts = data['counts'];
    final counts = (rawCounts is Map<String, dynamic>)
        ? SearchResultCounts.fromJson(rawCounts)
        : SearchResultCounts.empty;

    return SearchResultsResponse(
      items: items,
      meta: meta,
      activeTab: data['active_tab']?.toString() ?? '',
      counts: counts,
    );
  }
}
