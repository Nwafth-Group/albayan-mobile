
// ============================================
// FILE: lib/fatures/publishers/screens/cubit/publisher_state.dart
// ============================================

part of 'publisher_cubit.dart';

enum PublisherStatus { initial, loading, success, failure }

enum ListStatus { initial, loading, loadingMore, success, empty, failure }

class PublisherState extends Equatable {
  final PublisherStatus status;
  final PublisherDetailModel? publisher;
  final String? error;

  final ListStatus booksStatus;
  final List<BookModel> books;
  final PaginationMeta? booksMeta;

  const PublisherState({
    this.status = PublisherStatus.initial,
    this.publisher,
    this.error,
    this.booksStatus = ListStatus.initial,
    this.books = const [],
    this.booksMeta,
  });

  bool get booksHasMore => booksMeta?.hasMore ?? false;

  PublisherState copyWith({
    PublisherStatus? status,
    PublisherDetailModel? publisher,
    String? error,
    ListStatus? booksStatus,
    List<BookModel>? books,
    PaginationMeta? booksMeta,
  }) {
    return PublisherState(
      status: status ?? this.status,
      publisher: publisher ?? this.publisher,
      error: error,
      booksStatus: booksStatus ?? this.booksStatus,
      books: books ?? this.books,
      booksMeta: booksMeta ?? this.booksMeta,
    );
  }

  @override
  List<Object?> get props =>
      [status, publisher, error, booksStatus, books, booksMeta];
}
