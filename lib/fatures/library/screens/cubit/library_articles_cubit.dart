// ============================================
// FILE: lib/fatures/library/screens/cubit/library_articles_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/library_remote_data_source.dart';
import '../../utils/library_events.dart';
import '../../data/models/library_article_model.dart';

part 'library_articles_state.dart';

class LibraryArticlesCubit extends Cubit<LibraryArticlesState> {
  StreamSubscription<void>? _libraryChangesSub;

  @override
  Future<void> close() {
    _libraryChangesSub?.cancel();
    return super.close();
  }

  final LibraryRemoteDataSource dataSource;

  LibraryArticlesCubit(this.dataSource) : super(const LibraryArticlesState()) {
    // Refresh whenever a free item is added to My Library elsewhere.
    _libraryChangesSub = LibraryEvents.changes.listen((_) => refresh());
  }

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh: re-fetches page 1 but keeps the current list on
  /// screen (no full-screen loader) until the new page arrives.
  Future<void> refresh() => _fetch(page: 1, reset: true, silent: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Local removal — no delete endpoint is available yet.
  void remove(String id) {
    final updated = state.articles.where((a) => a.id != id).toList();
    emit(
      state.copyWith(
        articles: updated,
        status: updated.isEmpty && state.status == LibraryArticlesStatus.success
            ? LibraryArticlesStatus.empty
            : state.status,
      ),
    );
  }

  Future<void> _fetch({
    required int page,
    required bool reset,
    bool silent = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!silent) {
      emit(
        state.copyWith(
          status: reset
              ? LibraryArticlesStatus.loading
              : LibraryArticlesStatus.loadingMore,
          error: null,
        ),
      );
    }

    try {
      final result = await dataSource.getMagazineArticles(page: page);
      final merged = reset
          ? result.items
          : [...state.articles, ...result.items];

      emit(
        state.copyWith(
          status: merged.isEmpty
              ? LibraryArticlesStatus.empty
              : LibraryArticlesStatus.success,
          articles: merged,
          meta: result.meta,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: state.articles.isEmpty
              ? LibraryArticlesStatus.failure
              : LibraryArticlesStatus.success,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }
}
