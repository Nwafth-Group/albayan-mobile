
// ============================================
// FILE: lib/fatures/library/data/models/library_book_model.dart
// ============================================
//
// Shared shape for the "Books" and "My Documents" grids — both render as a
// cover with a delete badge, title, author, and a reading-progress bar.

import '../../../issues/data/models/pagination_meta.dart';

class LibraryBookModel {
  final String id;
  final String title;
  final String author;
  final String? cover;

  /// Reading progress, 0.0 (not started) to 1.0 (finished).
  final double progress;

  const LibraryBookModel({
    required this.id,
    required this.title,
    required this.author,
    this.cover,
    this.progress = 0,
  });

  /// Parses one item of `GET /reader/my-library/books`.
  factory LibraryBookModel.fromJson(Map<String, dynamic> json) {
    final rawAuthor = json['author'];
    return LibraryBookModel(
      id: json['id']?.toString() ?? '',
      title: (json['name'] ?? json['title'])?.toString() ?? '',
      author: rawAuthor is Map<String, dynamic>
          ? (rawAuthor['name']?.toString() ?? '')
          : (rawAuthor?.toString() ?? ''),
      cover: (json['cover'] ?? json['cover_image'] ?? json['image'])
          ?.toString(),
      progress: (json['progress'] is num)
          ? (json['progress'] as num).toDouble()
          : double.tryParse(json['progress']?.toString() ?? '') ?? 0,
    );
  }
}

class LibraryBooksResponse {
  final List<LibraryBookModel> items;
  final PaginationMeta meta;

  const LibraryBooksResponse({required this.items, required this.meta});

  /// Parses the `data` object: `{ "items": [...], "meta": {...} }`.
  factory LibraryBooksResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(LibraryBookModel.fromJson)
            .toList()
        : <LibraryBookModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return LibraryBooksResponse(items: items, meta: meta);
  }
}
