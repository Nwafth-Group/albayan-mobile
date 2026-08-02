
// ============================================
// FILE: lib/fatures/corners/data/models/corners_list_response.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

import 'corner_model.dart';

class CornersListResponse {
  final List<CornerModel> items;
  final PaginationMeta meta;

  const CornersListResponse({
    required this.items,
    required this.meta,
  });

  /// Parses the `data` object (which contains `items` + `meta`).
  factory CornersListResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(CornerModel.fromJson)
            .toList()
        : <CornerModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return CornersListResponse(items: items, meta: meta);
  }
}
