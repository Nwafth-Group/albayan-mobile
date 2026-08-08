
// ============================================
// FILE: lib/fatures/books/screens/cubit/books_list_state.dart
// ============================================

part of 'books_list_cubit.dart';

enum BooksListStatus { initial, loading, loadingMore, success, empty, failure }

class BooksListState extends Equatable {
  final BooksListStatus status;
  final List<BookModel> books;
  final PaginationMeta? meta;
  final BooksFilter filter;
  final String? error;

  const BooksListState({
    this.status = BooksListStatus.initial,
    this.books = const [],
    this.meta,
    this.filter = const BooksFilter(),
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == BooksListStatus.loading;
  bool get isLoadingMore => status == BooksListStatus.loadingMore;

  BooksListState copyWith({
    BooksListStatus? status,
    List<BookModel>? books,
    PaginationMeta? meta,
    BooksFilter? filter,
    String? error,
  }) {
    return BooksListState(
      status: status ?? this.status,
      books: books ?? this.books,
      meta: meta ?? this.meta,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, books, meta, filter, error];
}
