// ============================================
// FILE: lib/fatures/reader/data/models/reader_models.dart
// ============================================
//
// Models for the in-app PDF reader (ported from the E-Book app's
// DocumentScreen, reduced to what a remote PDF needs).

/// What the reader needs to open a book. Build it from any book/issue model
/// once the API returns a PDF url, e.g.
/// `ReaderBook(id: book.id, title: book.name, pdfUrl: book.pdfUrl!)`.
/// What kind of content a [ReaderBook] syncs progress for — each has its own
/// sync endpoint (`/reader/my-library/books/sync` vs
/// `/reader/my-library/documents/sync`).
enum ReaderContentKind { book, document }

class ReaderBook {
  /// Stable id — used to remember progress, bookmarks and highlights, and to
  /// name the cached file. Use the same id every time for the same book.
  final String id;
  final String title;
  final String pdfUrl;

  /// A free preview (`file_type: free`) rather than the full book.
  final bool isSample;

  /// The book/book-version UUID as the backend knows it (no `_free`/`_paid`
  /// suffix) — what the `/reader/my-library/books/sync` API expects as
  /// `my_books[].id`. Falls back to [id] when not set explicitly.
  final String apiBookId;

  final ReaderContentKind kind;

  const ReaderBook({
    required this.id,
    required this.title,
    required this.pdfUrl,
    this.isSample = false,
    this.kind = ReaderContentKind.book,
    String? apiBookId,
  }) : apiBookId = apiBookId ?? id;

  /// From an API book's `file_url` / `file_type`. The sample and the full
  /// book get different ids, so each keeps its own progress and bookmarks.
  /// Returns null when there's no file to read.
  static ReaderBook? fromFile({
    required String id,
    required String title,
    required String? fileUrl,
    String? fileType,
  }) {
    if (fileUrl == null || fileUrl.trim().isEmpty) return null;
    final type = fileType ?? 'paid';
    return ReaderBook(
      id: '${id}_$type',
      apiBookId: id,
      title: title,
      pdfUrl: fileUrl.trim(),
      isSample: type == 'free',
    );
  }
}

class ReaderBookmark {
  final int page;
  final DateTime createdAt;

  const ReaderBookmark({required this.page, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'page': page,
        'created_at': createdAt.toIso8601String(),
      };

  factory ReaderBookmark.fromJson(Map<String, dynamic> json) => ReaderBookmark(
        page: (json['page'] as num?)?.toInt() ?? 1,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  /// Shape expected by `my_books[].bookmarks[]` on the sync endpoint.
  Map<String, dynamic> toSyncJson() => {'page': page};
}

class ReaderHighlight {
  final int page;
  final String text;

  /// Selection bounds in PDF page coordinates: [left, top, right, bottom].
  final List<double> bounds;

  const ReaderHighlight({
    required this.page,
    required this.text,
    required this.bounds,
  });

  Map<String, dynamic> toJson() => {
        'page': page,
        'text': text,
        'bounds': bounds,
      };

  factory ReaderHighlight.fromJson(Map<String, dynamic> json) =>
      ReaderHighlight(
        page: (json['page'] as num?)?.toInt() ?? 1,
        text: json['text']?.toString() ?? '',
        bounds: (json['bounds'] as List? ?? const [])
            .map((e) => (e as num).toDouble())
            .toList(),
      );

  /// Shape expected by `my_books[].highlights[]` on the sync endpoint:
  /// `bounds` as `{x, y, width, height}` rather than the local LTRB list.
  Map<String, dynamic> toSyncJson() => {
        'page': page,
        'text': text,
        'bounds': bounds.length == 4
            ? {
                'x': bounds[0],
                'y': bounds[1],
                'width': bounds[2] - bounds[0],
                'height': bounds[3] - bounds[1],
              }
            : null,
      };
}

/// Everything remembered locally for one book.
class ReaderProgress {
  final int lastPage;
  final int totalPages;
  final List<ReaderBookmark> bookmarks;
  final List<ReaderHighlight> highlights;

  const ReaderProgress({
    this.lastPage = 1,
    this.totalPages = 0,
    this.bookmarks = const [],
    this.highlights = const [],
  });

  Map<String, dynamic> toJson() => {
        'last_page': lastPage,
        'total_pages': totalPages,
        'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
        'highlights': highlights.map((h) => h.toJson()).toList(),
      };

  factory ReaderProgress.fromJson(Map<String, dynamic> json) => ReaderProgress(
        lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
        bookmarks: (json['bookmarks'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ReaderBookmark.fromJson)
            .toList(),
        highlights: (json['highlights'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ReaderHighlight.fromJson)
            .toList(),
      );
}

// ── POST /reader/my-library/books/sync request body ──────────

/// One `my_books[]` entry: a book's reading progress, highlights and
/// bookmarks as the sync endpoint expects them. Built from a [ReaderBook]
/// and its locally-saved [ReaderProgress].
class BookSyncItem {
  final String id;
  final int currentPage;
  final int? totalPages;
  final List<ReaderHighlight> highlights;
  final List<ReaderBookmark> bookmarks;

  const BookSyncItem({
    required this.id,
    required this.currentPage,
    this.totalPages,
    this.highlights = const [],
    this.bookmarks = const [],
  });

  factory BookSyncItem.fromBook(ReaderBook book, ReaderProgress progress) =>
      BookSyncItem(
        id: book.apiBookId,
        currentPage: progress.lastPage,
        totalPages: progress.totalPages > 0 ? progress.totalPages : null,
        highlights: progress.highlights,
        bookmarks: progress.bookmarks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'current_page': currentPage,
        if (totalPages != null) 'total_pages': totalPages,
        'highlights': highlights.map((h) => h.toSyncJson()).toList(),
        'bookmarks': bookmarks.map((b) => b.toSyncJson()).toList(),
      };
}

/// Viewer preferences shared by every book.
class ReaderSettings {
  final bool isContinuous;
  final bool isHorizontal;

  const ReaderSettings({this.isContinuous = true, this.isHorizontal = false});

  ReaderSettings copyWith({bool? isContinuous, bool? isHorizontal}) =>
      ReaderSettings(
        isContinuous: isContinuous ?? this.isContinuous,
        isHorizontal: isHorizontal ?? this.isHorizontal,
      );
}
