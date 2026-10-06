// ============================================
// FILE: lib/fatures/reader/data/models/reader_models.dart
// ============================================
//
// Models for the in-app PDF reader (ported from the E-Book app's
// DocumentScreen, reduced to what a remote PDF needs).

/// What the reader needs to open a book. Build it from any book/issue model
/// once the API returns a PDF url, e.g.
/// `ReaderBook(id: book.id, title: book.name, pdfUrl: book.pdfUrl!)`.
class ReaderBook {
  /// Stable id — used to remember progress, bookmarks and highlights, and to
  /// name the cached file. Use the same id every time for the same book.
  final String id;
  final String title;
  final String pdfUrl;

  /// A free preview (`file_type: free`) rather than the full book.
  final bool isSample;

  const ReaderBook({
    required this.id,
    required this.title,
    required this.pdfUrl,
    this.isSample = false,
  });

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
