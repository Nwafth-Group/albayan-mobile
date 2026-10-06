// ============================================
// FILE: lib/fatures/issues/data/models/archive_year_model.dart
// ============================================
//
// One entry of `GET /public/issues/archive-years`'s `data.items`:
// { "h_year": 1447, "g_year": 2026, "display_name": "1447 H / 2026 G" }

import 'pagination_meta.dart';

class ArchiveYearModel {
  final int hYear;
  final int gYear;
  final String displayName;

  const ArchiveYearModel({
    required this.hYear,
    required this.gYear,
    required this.displayName,
  });

  factory ArchiveYearModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    final h = toInt(json['h_year']);
    final g = toInt(json['g_year']);
    return ArchiveYearModel(
      hYear: h,
      gYear: g,
      displayName: json['display_name']?.toString() ?? '$h H / $g G',
    );
  }
}

class ArchiveYearsResponse {
  final List<ArchiveYearModel> items;
  final PaginationMeta meta;

  const ArchiveYearsResponse({required this.items, required this.meta});

  factory ArchiveYearsResponse.fromData(Map<String, dynamic> data) {
    final rawItems = (data['items'] as List?) ?? const [];
    return ArchiveYearsResponse(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(ArchiveYearModel.fromJson)
          .toList(),
      meta: data['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>)
          : PaginationMeta.empty,
    );
  }
}
