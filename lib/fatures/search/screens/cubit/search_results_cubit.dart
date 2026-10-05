
// ============================================
// FILE: lib/fatures/search/screens/cubit/search_results_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/data/favorites_sync.dart';
import '../../../favorites/data/models/favorite_item_model.dart';
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
      : super(const SearchResultsState()) {
    // Keep this tab's hearts in sync with changes made elsewhere.
    _favoriteSub = FavoritesSync.changes.listen((c) {
      if (c.type == _favoriteType) _setFavorite(c.id, c.isFavorite);
    });
  }

  bool _isFetching = false;
  late final StreamSubscription<FavoriteChange> _favoriteSub;

  @override
  Future<void> close() {
    _favoriteSub.cancel();
    return super.close();
  }

  /// The favorite type of this tab's results (one content type per tab).
  FavoriteType? get _favoriteType {
    switch (filter.contentType) {
      case 'articles':
        return FavoriteType.article;
      case 'books':
        return FavoriteType.book;
      case 'issues':
        return FavoriteType.issue;
      default:
        return null;
    }
  }

  /// Favorites identify a book by its version id.
  String _favoriteId(SearchResultItemModel item) =>
      _favoriteType == FavoriteType.book ? (item.versionId ?? item.id) : item.id;

  /// POST /reader/favorites/toggle — optimistic, settles on the server's
  /// answer (see [FavoritesSync.toggleOptimistic]).
  Future<void> toggleFavorite(SearchResultItemModel item) async {
    final type = _favoriteType;
    if (type == null) return;
    final id = _favoriteId(item);
    await FavoritesSync.toggleOptimistic(
      type: type,
      id: id,
      current: item.isFavorite,
      apply: (isFavorite) => _setFavorite(id, isFavorite),
    );
  }

  void _setFavorite(String favoriteId, bool isFavorite) {
    if (isClosed) return;
    var changed = false;
    final updated = state.items.map((i) {
      if (_favoriteId(i) != favoriteId || i.isFavorite == isFavorite) return i;
      changed = true;
      return i.copyWith(isFavorite: isFavorite);
    }).toList();
    if (changed) emit(state.copyWith(items: updated));
  }

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
