
// ============================================
// FILE: lib/fatures/library/data/models/library_section_model.dart
// ============================================
//
// NOTE: No backend endpoint for the reader's library has been provided yet.
// This model and the mock data in `library_mock_data.dart` exist so the UI
// can be built and reviewed now. Once a real `/reader/library` (or similar)
// endpoint exists, replace the mock file with a datasource/cubit that parses
// JSON into this same model shape.

enum LibrarySectionType { books, documents, magazine }

class LibrarySectionModel {
  final LibrarySectionType type;

  /// Translation key for the card title, e.g. `library_books`.
  final String titleKey;

  /// Translation key for the "{count} …" line under the title.
  final String countKey;

  final int count;

  const LibrarySectionModel({
    required this.type,
    required this.titleKey,
    required this.countKey,
    required this.count,
  });
}
