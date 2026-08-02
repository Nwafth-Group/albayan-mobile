
// ============================================
// FILE: lib/fatures/articles/screens/cubit/articles_list_state.dart
// ============================================

part of 'articles_list_cubit.dart';

enum ArticlesListStatus { initial, loading, loadingMore, success, empty, failure }

class ArticlesListState extends Equatable {
  final ArticlesListStatus status;
  final List<CornerArticleModel> articles;
  final PaginationMeta? meta;
  final ArticlesFilter filter;
  final String? error;

  const ArticlesListState({
    this.status = ArticlesListStatus.initial,
    this.articles = const [],
    this.meta,
    this.filter = const ArticlesFilter(),
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == ArticlesListStatus.loading;
  bool get isLoadingMore => status == ArticlesListStatus.loadingMore;

  ArticlesListState copyWith({
    ArticlesListStatus? status,
    List<CornerArticleModel>? articles,
    PaginationMeta? meta,
    ArticlesFilter? filter,
    String? error,
  }) {
    return ArticlesListState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      meta: meta ?? this.meta,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, articles, meta, filter, error];
}
