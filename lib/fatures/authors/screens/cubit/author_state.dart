
// ============================================
// FILE: lib/fatures/authors/screens/cubit/author_state.dart
// ============================================

part of 'author_cubit.dart';

enum AuthorStatus { initial, loading, success, failure }

enum ListStatus { initial, loading, loadingMore, success, empty, failure }

class AuthorState extends Equatable {
  final AuthorStatus status;
  final AuthorDetailsModel? author;
  final String? error;

  // Articles
  final ListStatus articlesStatus;
  final List<CornerArticleModel> articles;
  final PaginationMeta? articlesMeta;
  final List<int> years;
  final int? selectedYear;

  // Books
  final ListStatus booksStatus;
  final List<BookModel> books;
  final PaginationMeta? booksMeta;

  const AuthorState({
    this.status = AuthorStatus.initial,
    this.author,
    this.error,
    this.articlesStatus = ListStatus.initial,
    this.articles = const [],
    this.articlesMeta,
    this.years = const [],
    this.selectedYear,
    this.booksStatus = ListStatus.initial,
    this.books = const [],
    this.booksMeta,
  });

  bool get articlesHasMore => articlesMeta?.hasMore ?? false;
  bool get booksHasMore => booksMeta?.hasMore ?? false;

  int get collectionsCount =>
      (articlesMeta?.total ?? 0) + (booksMeta?.total ?? 0);

  AuthorState copyWith({
    AuthorStatus? status,
    AuthorDetailsModel? author,
    String? error,
    ListStatus? articlesStatus,
    List<CornerArticleModel>? articles,
    PaginationMeta? articlesMeta,
    List<int>? years,
    int? selectedYear,
    ListStatus? booksStatus,
    List<BookModel>? books,
    PaginationMeta? booksMeta,
  }) {
    return AuthorState(
      status: status ?? this.status,
      author: author ?? this.author,
      error: error,
      articlesStatus: articlesStatus ?? this.articlesStatus,
      articles: articles ?? this.articles,
      articlesMeta: articlesMeta ?? this.articlesMeta,
      years: years ?? this.years,
      selectedYear: selectedYear ?? this.selectedYear,
      booksStatus: booksStatus ?? this.booksStatus,
      books: books ?? this.books,
      booksMeta: booksMeta ?? this.booksMeta,
    );
  }

  @override
  List<Object?> get props => [
    status,
    author,
    error,
    articlesStatus,
    articles,
    articlesMeta,
    years,
    selectedYear,
    booksStatus,
    books,
    booksMeta,
  ];
}