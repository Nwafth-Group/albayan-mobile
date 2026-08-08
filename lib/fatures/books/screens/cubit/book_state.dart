
// ============================================
// FILE: lib/fatures/books/screens/cubit/book_state.dart
// ============================================

part of 'book_cubit.dart';

enum BookStatus { initial, loading, success, failure }

enum ListStatus { initial, loading, loadingMore, success, empty, failure }

class BookState extends Equatable {
  // Detail
  final BookStatus status;
  final BookDetailModel? book;
  final String? error;

  // Comments / reviews
  final ListStatus commentsStatus;
  final List<CommentModel> comments;
  final PaginationMeta? commentsMeta;

  // Related
  final ListStatus relatedStatus;
  final List<BookModel> related;
  final PaginationMeta? relatedMeta;

  // Rating submission
  final bool submittingRating;

  const BookState({
    this.status = BookStatus.initial,
    this.book,
    this.error,
    this.commentsStatus = ListStatus.initial,
    this.comments = const [],
    this.commentsMeta,
    this.relatedStatus = ListStatus.initial,
    this.related = const [],
    this.relatedMeta,
    this.submittingRating = false,
  });

  bool get commentsHasMore => commentsMeta?.hasMore ?? false;
  bool get relatedHasMore => relatedMeta?.hasMore ?? false;

  BookState copyWith({
    BookStatus? status,
    BookDetailModel? book,
    String? error,
    ListStatus? commentsStatus,
    List<CommentModel>? comments,
    PaginationMeta? commentsMeta,
    ListStatus? relatedStatus,
    List<BookModel>? related,
    PaginationMeta? relatedMeta,
    bool? submittingRating,
  }) {
    return BookState(
      status: status ?? this.status,
      book: book ?? this.book,
      error: error,
      commentsStatus: commentsStatus ?? this.commentsStatus,
      comments: comments ?? this.comments,
      commentsMeta: commentsMeta ?? this.commentsMeta,
      relatedStatus: relatedStatus ?? this.relatedStatus,
      related: related ?? this.related,
      relatedMeta: relatedMeta ?? this.relatedMeta,
      submittingRating: submittingRating ?? this.submittingRating,
    );
  }

  @override
  List<Object?> get props => [
        status,
        book,
        error,
        commentsStatus,
        comments,
        commentsMeta,
        relatedStatus,
        related,
        relatedMeta,
        submittingRating,
      ];
}
