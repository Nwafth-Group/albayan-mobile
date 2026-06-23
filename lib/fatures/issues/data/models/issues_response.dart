
// ============================================
// FILE: lib/fatures/issues/data/models/issues_response.dart
// ============================================

import 'issue_model.dart';
import 'pagination_meta.dart';

class IssuesResponse {
  final List<IssueModel> items;
  final PaginationMeta meta;

  const IssuesResponse({required this.items, required this.meta});

  /// Parses the `data` object of the API response:
  /// { "items": [...], "links": {...}, "meta": {...} }
  factory IssuesResponse.fromData(Map<String, dynamic> data) {
    final rawItems = (data['items'] as List?) ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(IssueModel.fromJson)
        .toList();

    final meta = data['meta'] is Map<String, dynamic>
        ? PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>)
        : PaginationMeta.empty;

    return IssuesResponse(items: items, meta: meta);
  }
}