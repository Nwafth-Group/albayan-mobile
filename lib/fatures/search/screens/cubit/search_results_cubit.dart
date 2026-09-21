
// ============================================
// FILE: lib/fatures/search/screens/cubit/search_results_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/search_remote_data_source.dart';
import '../../data/models/advanced_search_filter.dart';
import '../../data/models/search_result_item_model.dart';

part 'search_results_state.dart';

/// Drives one results tab (articles / books / issues) of `GET /public/search`.
/// [filter] already has `contentType` set to this tab's type.
class SearchResultsCubit extends Cubit<SearchResultsState> {
  final SearchRemoteDataSource dataSource;
  final AdvancedSearchFilter filter;

  SearchResultsCubit(this.dataSource, this.filter)
      : super(const SearchResultsState());

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  Future<void> refresh() => _fetch(page: 1, reset: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    // Reloading while results are visible keeps them on screen and only
    // flags a background refresh; the full-screen spinner is for first loads.
    final hasVisible = reset && state.items.isNotEmpty;
    emit(state.copyWith(
      status: hasVisible
          ? state.status
          : (reset
              ? SearchResultsStatus.loading
              : SearchResultsStatus.loadingMore),
      isRefreshing: hasVisible,
      error: null,
    ));

    try {
      final result = await dataSource.search(filter: filter, page: page);
      final merged = reset ? result.items : [...state.items, ...result.items];

      emit(state.copyWith(
        status: merged.isEmpty
            ? SearchResultsStatus.empty
            : SearchResultsStatus.success,
        items: merged,
        meta: result.meta,
        counts: result.counts,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.items.isEmpty
            ? SearchResultsStatus.failure
            : SearchResultsStatus.success,
        error: e.toString(),
        isRefreshing: false,
      ));
    } finally {
      _isFetching = false;
    }
  }
}
