
// ============================================
// FILE: lib/fatures/corners/screens/cubit/corner_state.dart
// ============================================

part of 'corner_cubit.dart';

enum CornerStatus { initial, loading, loadingMore, success, empty, failure }

class CornerState extends Equatable {
  final CornerStatus status;
  final CornerModel? corner;
  final List<CornerArticleModel> articles;
  final PaginationMeta? meta;
  final CornerArticlesFilter filter;
  final String? error;

  const CornerState({
    this.status = CornerStatus.initial,
    this.corner,
    this.articles = const [],
    this.meta,
    this.filter = const CornerArticlesFilter(),
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == CornerStatus.loading;
  bool get isLoadingMore => status == CornerStatus.loadingMore;

  CornerState copyWith({
    CornerStatus? status,
    CornerModel? corner,
    List<CornerArticleModel>? articles,
    PaginationMeta? meta,
    CornerArticlesFilter? filter,
    String? error,
  }) {
    return CornerState(
      status: status ?? this.status,
      corner: corner ?? this.corner,
      articles: articles ?? this.articles,
      meta: meta ?? this.meta,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, corner, articles, meta, filter, error];
}