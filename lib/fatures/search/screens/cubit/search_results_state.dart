
// ============================================
// FILE: lib/fatures/search/screens/cubit/search_results_state.dart
// ============================================

part of 'search_results_cubit.dart';

enum SearchResultsStatus {
  initial,
  loading,
  loadingMore,
  success,
  empty,
  failure,
}

class SearchResultsState extends Equatable {
  final SearchResultsStatus status;
  final List<SearchResultItemModel> items;
  final PaginationMeta? meta;
  final SearchResultCounts? counts;
  final String? error;

  /// True while a reload runs on top of already-visible results.
  final bool isRefreshing;

  const SearchResultsState({
    this.status = SearchResultsStatus.initial,
    this.items = const [],
    this.meta,
    this.counts,
    this.error,
    this.isRefreshing = false,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == SearchResultsStatus.loading;
  bool get isLoadingMore => status == SearchResultsStatus.loadingMore;

  SearchResultsState copyWith({
    SearchResultsStatus? status,
    List<SearchResultItemModel>? items,
    PaginationMeta? meta,
    SearchResultCounts? counts,
    String? error,
    bool? isRefreshing,
  }) {
    return SearchResultsState(
      status: status ?? this.status,
      items: items ?? this.items,
      meta: meta ?? this.meta,
      counts: counts ?? this.counts,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, meta, counts, error, isRefreshing];
}
