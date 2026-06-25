
// ============================================
// FILE: lib/fatures/corners/screens/cubit/corner_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  CornerCubit(
      this.dataSource, {
        required this.cornerId,
      }) : super(const CornerState());

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

  /// Optimistic favorite toggle (wire the real endpoint here when available).
  void toggleFavorite(String articleId) {
    final updated = state.articles
        .map((a) => a.id == articleId
        ? a.copyWith(isFavorite: !a.isFavorite)
        : a)
        .toList();
    emit(state.copyWith(articles: updated));
    // TODO: call favorite/unfavorite endpoint and revert on failure.
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
    return super.close();
  }
}