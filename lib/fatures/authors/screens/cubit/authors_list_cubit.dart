
// ============================================
// FILE: lib/fatures/authors/screens/cubit/authors_list_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/authors_remote_data_source.dart';
import '../../data/models/author_list_model.dart';

part 'authors_list_state.dart';

class AuthorsListCubit extends Cubit<AuthorsListState> {
  final AuthorsRemoteDataSource dataSource;

  AuthorsListCubit(this.dataSource) : super(const AuthorsListState());

  Timer? _searchDebounce;
  bool _isFetching = false;

  /// First load.
  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh.
  Future<void> refresh() => _fetch(page: 1, reset: true);

  /// Loads the next page if available.
  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Debounced search by author name.
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      emit(state.copyWith(query: query.trim()));
      _fetch(page: 1, reset: true);
    });
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(state.copyWith(
      status: reset ? AuthorsListStatus.loading : AuthorsListStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getAuthors(
        search: state.query,
        page: page,
      );

      final merged =
          reset ? result.items : [...state.authors, ...result.items];

      emit(state.copyWith(
        status: merged.isEmpty
            ? AuthorsListStatus.empty
            : AuthorsListStatus.success,
        authors: merged,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.authors.isEmpty
            ? AuthorsListStatus.failure
            : AuthorsListStatus.success,
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
