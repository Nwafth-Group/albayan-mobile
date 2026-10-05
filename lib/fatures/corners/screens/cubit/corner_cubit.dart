
// ============================================
// FILE: lib/fatures/corners/screens/cubit/corner_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:albayan/fatures/favorites/data/favorites_sync.dart';
import 'package:albayan/fatures/favorites/data/models/favorite_item_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

import '../../data/datasource/corners_remote_data_source.dart';
import '../../data/models/corner_article_model.dart';
import '../../data/models/corner_articles_filter.dart';
import '../../data/models/corner_model.dart';

part 'corner_state.dart';

class CornerCubit extends Cubit<CornerState> {
  final CornersRemoteDataSource dataSource;
  final String cornerId;

  Timer? _searchDebounce;
  bool _isFetching = false;
  late final StreamSubscription<FavoriteChange> _favoriteSub;

  CornerCubit(
      this.dataSource, {
        required this.cornerId,
      }) : super(const CornerState()) {
    // Keep hearts in sync when an article is (un)favorited elsewhere.
    _favoriteSub = FavoritesSync.changes.listen((c) {
      if (c.type == FavoriteType.article) _setFavorite(c.id, c.isFavorite);
    });
  }

  /// Loads the corner header + the first page of articles.
  Future<void> load() async {
    emit(state.copyWith(status: CornerStatus.loading, error: null));
    try {
      final corner = await dataSource.getCorner(cornerId);
      emit(state.copyWith(corner: corner));
      await _fetch(page: 1, reset: true);
    } catch (e) {
      emit(state.copyWith(status: CornerStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  Future<void> refresh() => _fetch(page: 1, reset: true);

  /// Debounced text search.
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      emit(state.copyWith(filter: state.filter.setSearch(query)));
      _fetch(page: 1, reset: true);
    });
  }

  Future<void> applyDates({DateTime? start, DateTime? end}) async {
    emit(state.copyWith(filter: state.filter.setDates(start: start, end: end)));
    await _fetch(page: 1, reset: true);
  }

  Future<void> resetDates() async {
    emit(state.copyWith(filter: state.filter.clearDates()));
    await _fetch(page: 1, reset: true);
  }

  /// POST /reader/favorites/toggle — optimistic, settles on the server's
  /// answer (see [FavoritesSync.toggleOptimistic]).
  Future<void> toggleFavorite(String articleId) async {
    final article = state.articles.where((a) => a.id == articleId).firstOrNull;
    if (article == null) return;
    await FavoritesSync.toggleOptimistic(
      type: FavoriteType.article,
      id: articleId,
      current: article.isFavorite,
      apply: (isFavorite) => _setFavorite(articleId, isFavorite),
    );
  }

  void _setFavorite(String articleId, bool isFavorite) {
    if (isClosed) return;
    var changed = false;
    final updated = state.articles.map((a) {
      if (a.id != articleId || a.isFavorite == isFavorite) return a;
      changed = true;
      return a.copyWith(isFavorite: isFavorite);
    }).toList();
    if (changed) emit(state.copyWith(articles: updated));
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(state.copyWith(
      status: reset ? CornerStatus.loading : CornerStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getCornerArticles(
        id: cornerId,
        filter: state.filter,
        page: page,
      );

      final merged =
      reset ? result.items : [...state.articles, ...result.items];

      emit(state.copyWith(
        status: merged.isEmpty ? CornerStatus.empty : CornerStatus.success,
        articles: merged,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.articles.isEmpty
            ? CornerStatus.failure
            : CornerStatus.success,
        error: e.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _favoriteSub.cancel();
    return super.close();
  }
}