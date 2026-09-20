
// ============================================
// FILE: lib/fatures/library/screens/cubit/library_articles_state.dart
// ============================================

part of 'library_articles_cubit.dart';

enum LibraryArticlesStatus { initial, loading, loadingMore, success, empty, failure }

class LibraryArticlesState extends Equatable {
  final LibraryArticlesStatus status;
  final List<LibraryArticleModel> articles;
  final PaginationMeta? meta;
  final String? error;

  const LibraryArticlesState({
    this.status = LibraryArticlesStatus.initial,
    this.articles = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == LibraryArticlesStatus.loading;
  bool get isLoadingMore => status == LibraryArticlesStatus.loadingMore;

  LibraryArticlesState copyWith({
    LibraryArticlesStatus? status,
    List<LibraryArticleModel>? articles,
    PaginationMeta? meta,
    String? error,
  }) {
    return LibraryArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, articles, meta, error];
}
