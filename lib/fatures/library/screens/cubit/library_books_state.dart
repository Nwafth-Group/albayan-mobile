
// ============================================
// FILE: lib/fatures/library/screens/cubit/library_books_state.dart
// ============================================

part of 'library_books_cubit.dart';

enum LibraryBooksStatus { initial, loading, loadingMore, success, empty, failure }

class LibraryBooksState extends Equatable {
  final LibraryBooksStatus status;
  final List<LibraryBookModel> books;
  final PaginationMeta? meta;
  final String? error;

  const LibraryBooksState({
    this.status = LibraryBooksStatus.initial,
    this.books = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == LibraryBooksStatus.loading;
  bool get isLoadingMore => status == LibraryBooksStatus.loadingMore;

  LibraryBooksState copyWith({
    LibraryBooksStatus? status,
    List<LibraryBookModel>? books,
    PaginationMeta? meta,
    String? error,
  }) {
    return LibraryBooksState(
      status: status ?? this.status,
      books: books ?? this.books,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, books, meta, error];
}
