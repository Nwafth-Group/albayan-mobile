
// ============================================
// FILE: lib/fatures/articles/screens/cubit/articles_list_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../corners/data/models/corner_article_model.dart';
import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/articles_remote_data_source.dart';
import '../../data/models/articles_filter.dart';

part 'articles_list_state.dart';

class ArticlesListCubit extends Cubit<ArticlesListState> {
  final ArticlesRemoteDataSource dataSource;

  ArticlesListCubit(this.dataSource) : super(const ArticlesListState());

  Timer? _searchDebounce;
  bool _isFetching = false;

  /// First load / reload with the current filter.
  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh.
  Future<void> refresh() => _fetch(page: 1, reset: true);

  /// Loads the next page if available.
  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Applies a new date filter (from the filter sheet) and reloads from page 1.
  Future<void> applyDates({DateTime? from, DateTime? to}) async {
    emit(state.copyWith(filter: state.filter.setDates(from: from, to: to)));
    await _fetch(page: 1, reset: true);
  }

  /// Clears the date filter only (keeps current search text).
  Future<void> resetDates() async {
    emit(state.copyWith(filter: state.filter.clearDates()));
    await _fetch(page: 1, reset: true);
  }

  /// Debounced free-text search.
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      emit(state.copyWith(filter: state.filter.setSearch(query)));
      _fetch(page: 1, reset: true);
    });
  }

  /// Local optimistic favorite toggle.
  void toggleFavorite(String articleId) {
    final updated = state.articles
        .map((a) =>
            a.id == articleId ? a.copyWith(isFavorite: !a.isFavorite) : a)
        .toList();
    emit(state.copyWith(articles: updated));
    // TODO: call favorite/unfavorite endpoint and revert on failure.
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(state.copyWith(
      status:
          reset ? ArticlesListStatus.loading : ArticlesListStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getArticles(
        filter: state.filter,
        page: page,
      );

      final merged =
          reset ? result.items : [...state.articles, ...result.items];

      emit(state.copyWith(
        status: merged.isEmpty
            ? ArticlesListStatus.empty
            : ArticlesListStatus.success,
        articles: merged,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.articles.isEmpty
            ? ArticlesListStatus.failure
            : ArticlesListStatus.success,
        error: e.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
