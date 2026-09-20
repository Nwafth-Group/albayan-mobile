
// ============================================
// FILE: lib/fatures/library/data/models/library_issue_model.dart
// ============================================

import '../../../issues/data/models/pagination_meta.dart';

class LibraryIssueModel {
  final String id;
  final String title;
  final String? cover;
  final DateTime date;

  const LibraryIssueModel({
    required this.id,
    required this.title,
    this.cover,
    required this.date,
  });

  /// Parses one item of `GET /reader/my-library/magazine/issues`.
  factory LibraryIssueModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['published_at'] ?? json['date'] ?? json['saved_at'];
    return LibraryIssueModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      cover: (json['cover_image'] ?? json['cover'] ?? json['image'])
          ?.toString(),
      // Falls back to now when the backend omits a date so the UI still has
      // something to render — this endpoint's item shape wasn't documented.
      date: rawDate == null
          ? DateTime.now()
          : DateTime.tryParse(rawDate.toString())?.toLocal() ?? DateTime.now(),
    );
  }
}

class LibraryIssuesResponse {
  final List<LibraryIssueModel> items;
  final PaginationMeta meta;

  const LibraryIssuesResponse({required this.items, required this.meta});

  /// Parses the `data` object: `{ "items": [...], "meta": {...} }`.
  factory LibraryIssuesResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(LibraryIssueModel.fromJson)
            .toList()
        : <LibraryIssueModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return LibraryIssuesResponse(items: items, meta: meta);
  }
}
