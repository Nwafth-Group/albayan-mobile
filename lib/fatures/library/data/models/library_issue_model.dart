
// ============================================
// FILE: lib/fatures/library/data/models/library_issue_model.dart
// ============================================

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
}
