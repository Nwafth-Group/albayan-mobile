
// ============================================
// FILE: lib/fatures/library/data/models/library_article_model.dart
// ============================================

class LibraryArticleModel {
  final String id;

  /// Small line above the title, e.g. "Lorem lorem , 0908".
  final String subtitle;

  final String title;
  final String author;
  final String? image;
  final double rate;
  final DateTime date;

  const LibraryArticleModel({
    required this.id,
    required this.subtitle,
    required this.title,
    required this.author,
    this.image,
    required this.rate,
    required this.date,
  });
}
