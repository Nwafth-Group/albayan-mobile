
// ============================================
// FILE: lib/fatures/favorites/screens/cubit/favorites_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/favorites_remote_data_source.dart';
import '../../data/favorites_sync.dart';
import '../../data/models/favorite_item_model.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRemoteDataSource dataSource;

  bool _isFetching = false;
  late final StreamSubscription<FavoriteChange> _favoriteSub;

  FavoritesCubit(this.dataSource) : super(const FavoritesState()) {
    _favoriteSub = FavoritesSync.changes.listen(_onFavoriteChanged);
  }

  @override
  Future<void> close() {
    _favoriteSub.cancel();
    return super.close();
  }

  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh / silent resync — keeps the list on screen meanwhile.
  Future<void> refresh() => _fetch(page: 1, reset: true, silent: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Unfavorites [item]: it leaves the list at once, and comes back in the
  /// same spot if the request fails.
  Future<void> unfavorite(FavoriteItemModel item) async {
    final index = state.items.indexWhere((i) => _same(i, item));
    if (index < 0) return;
    await FavoritesSync.toggleOptimistic(
      type: item.type,
      id: item.itemId,
      current: true,
      apply: (isFavorite) =>
          isFavorite ? _reinsert(item, index) : _remove(item.type, item.itemId),
    );
  }

  /// A heart toggled anywhere else in the app.
  void _onFavoriteChanged(FavoriteChange change) {
    if (!change.isFavorite) {
      _remove(change.type, change.id);
    } else if (!state.items.any((i) => change.matches(i.type, i.itemId)) &&
        state.status != FavoritesStatus.initial) {
      // Newly favorited somewhere else — fetch it so it appears in place.
      refresh();
    }
  }

  bool _same(FavoriteItemModel a, FavoriteItemModel b) =>
      a.type == b.type && a.itemId == b.itemId;

  void _remove(FavoriteType type, String itemId) {
    if (isClosed) return;
    final updated = state.items
        .where((i) => !(i.type == type && i.itemId == itemId))
        .toList();
    if (updated.length == state.items.length) return;
    emit(state.copyWith(
      items: updated,
      status: updated.isEmpty ? FavoritesStatus.empty : FavoritesStatus.success,
    ));
  }

  void _reinsert(FavoriteItemModel item, int index) {
    if (isClosed || state.items.any((i) => _same(i, item))) return;
    final updated = [...state.items]
      ..insert(index.clamp(0, state.items.length), item);
    emit(state.copyWith(items: updated, status: FavoritesStatus.success));
  }

  Future<void> _fetch({
    required int page,
    required bool reset,
    bool silent = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    final keepVisible = silent && state.items.isNotEmpty;
    if (!keepVisible) {
      emit(state.copyWith(
        status: reset ? FavoritesStatus.loading : FavoritesStatus.loadingMore,
        error: null,
      ));
    }

    try {
      final result = await dataSource.getFavorites(page: page);
      if (isClosed) return;
      final merged = reset ? result.items : [...state.items, ...result.items];
      emit(state.copyWith(
        status:
            merged.isEmpty ? FavoritesStatus.empty : FavoritesStatus.success,
        items: merged,
        meta: result.meta,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: state.items.isEmpty
            ? FavoritesStatus.failure
            : FavoritesStatus.success,
        error: e.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }
}
