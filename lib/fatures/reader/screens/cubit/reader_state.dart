// ============================================
// FILE: lib/fatures/reader/screens/cubit/reader_state.dart
// ============================================

part of 'reader_cubit.dart';

enum ReaderStatus { downloading, ready, failure }

class ReaderState extends Equatable {
  final ReaderStatus status;

  /// Download progress 0..1 (only meaningful while [ReaderStatus.downloading]).
  final double progress;
  final File? file;
  final int currentPage;
  final int totalPages;
  final List<ReaderBookmark> bookmarks;
  final List<ReaderHighlight> highlights;
  final ReaderSettings settings;
  final String? error;

  /// The raw exception, shown under the message in debug builds only.
  final String? debugDetails;

  const ReaderState({
    this.status = ReaderStatus.downloading,
    this.progress = 0,
    this.file,
    this.currentPage = 1,
    this.totalPages = 0,
    this.bookmarks = const [],
    this.highlights = const [],
    this.settings = const ReaderSettings(),
    this.error,
    this.debugDetails,
  });

  bool get isCurrentPageBookmarked =>
      bookmarks.any((b) => b.page == currentPage);

  ReaderState copyWith({
    ReaderStatus? status,
    double? progress,
    File? file,
    int? currentPage,
    int? totalPages,
    List<ReaderBookmark>? bookmarks,
    List<ReaderHighlight>? highlights,
    ReaderSettings? settings,
    String? error,
    String? debugDetails,
  }) {
    return ReaderState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      file: file ?? this.file,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      bookmarks: bookmarks ?? this.bookmarks,
      highlights: highlights ?? this.highlights,
      settings: settings ?? this.settings,
      error: error,
      debugDetails: debugDetails,
    );
  }

  @override
  List<Object?> get props => [
        status,
        progress,
        file?.path,
        currentPage,
        totalPages,
        bookmarks,
        highlights,
        settings.isContinuous,
        settings.isHorizontal,
        error,
        debugDetails,
      ];
}
