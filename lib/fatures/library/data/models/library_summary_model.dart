
// ============================================
// FILE: lib/fatures/library/data/models/library_summary_model.dart
// ============================================
//
// Parses `GET /reader/my-library`:
// { "data": { "books_count", "my_documents_count",
//             "magazine_issues_count", "magazine_articles_count",
//             "magazine_total_count" } }

class LibrarySummaryModel {
  final int booksCount;
  final int myDocumentsCount;
  final int magazineIssuesCount;
  final int magazineArticlesCount;
  final int magazineTotalCount;

  const LibrarySummaryModel({
    this.booksCount = 0,
    this.myDocumentsCount = 0,
    this.magazineIssuesCount = 0,
    this.magazineArticlesCount = 0,
    this.magazineTotalCount = 0,
  });

  static const empty = LibrarySummaryModel();

  factory LibrarySummaryModel.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return LibrarySummaryModel(
      booksCount: parse(json['books_count']),
      myDocumentsCount: parse(json['my_documents_count']),
      magazineIssuesCount: parse(json['magazine_issues_count']),
      magazineArticlesCount: parse(json['magazine_articles_count']),
      magazineTotalCount: parse(json['magazine_total_count']),
    );
  }
}
