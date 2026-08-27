
// ============================================
// FILE: lib/fatures/library/data/models/library_book_model.dart
// ============================================
//
// Shared shape for the "Books" and "My Documents" grids — both render as a
// cover with a delete badge, title, author, and a reading-progress bar.

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
}
