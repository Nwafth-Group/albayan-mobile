
// ============================================
// FILE: lib/fatures/offers/screens/cubit/offers_list_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/offers_remote_data_source.dart';
import '../../data/models/offer_model.dart';

part 'offers_list_state.dart';

class OffersListCubit extends Cubit<OffersListState> {
  final OffersRemoteDataSource dataSource;

  OffersListCubit(this.dataSource) : super(const OffersListState());

  bool _isFetching = false;
  Timer? _searchDebounce;

  Future<void> load() => _fetch(page: 1, reset: true);

  Future<void> refresh() => _fetch(page: 1, reset: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Switch tab — `null` means "all".
  Future<void> changeType(OfferType? type) async {
    if (type == state.type) return;
    emit(state.copyWith(type: () => type));
    await _fetch(page: 1, reset: true, force: true);
  }

  /// Debounced free-text search (the `search` query param).
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      emit(state.copyWith(search: query.trim()));
      _fetch(page: 1, reset: true, force: true);
    });
  }

  /// Bumped by every [force]d fetch; a response from an older generation is
  /// dropped, so a slow request for the previous tab/search (or a load-more
  /// still in flight) can't overwrite the new list.
  int _generation = 0;

  /// [force] lets a tab/search change start while an older request is still
  /// running.
  Future<void> _fetch({
    required int page,
    required bool reset,
    bool force = false,
  }) async {
    if (_isFetching && !force) return;
    if (force) _generation++;
    final generation = _generation;
    _isFetching = true;

    emit(state.copyWith(
      status: reset ? OffersListStatus.loading : OffersListStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getOffers(
        type: state.type?.apiValue ?? 'all',
        search: state.search,
        page: page,
      );
      if (generation != _generation) return; // stale

      final merged = reset ? result.items : [...state.items, ...result.items];
      emit(state.copyWith(
        status:
            merged.isEmpty ? OffersListStatus.empty : OffersListStatus.success,
        items: merged,
        urgentOffer: () => result.urgentOffer ?? state.urgentOffer,
        meta: result.meta,
      ));
    } catch (e) {
      if (generation != _generation) return; // stale
      emit(state.copyWith(
        status: reset || state.items.isEmpty
            ? OffersListStatus.failure
            : OffersListStatus.success,
        error: e.toString(),
      ));
    } finally {
      if (generation == _generation) _isFetching = false;
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
