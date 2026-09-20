
// ============================================
// FILE: lib/fatures/library/screens/cubit/library_books_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/library_remote_data_source.dart';
import '../../data/models/library_book_model.dart';

part 'library_books_state.dart';

class LibraryBooksCubit extends Cubit<LibraryBooksState> {
  final LibraryRemoteDataSource dataSource;

  LibraryBooksCubit(this.dataSource) : super(const LibraryBooksState());

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  Future<void> refresh() => _fetch(page: 1, reset: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Local removal — no delete endpoint is available yet.
  void remove(String id) {
    final updated = state.books.where((b) => b.id != id).toList();
    emit(state.copyWith(
      books: updated,
      status: updated.isEmpty && state.status == LibraryBooksStatus.success
          ? LibraryBooksStatus.empty
          : state.status,
    ));
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(state.copyWith(
      status: reset ? LibraryBooksStatus.loading : LibraryBooksStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getBooks(page: page);
      final merged =
          reset ? result.items : [...state.books, ...result.items];

      emit(state.copyWith(
        status:
            merged.isEmpty ? LibraryBooksStatus.empty : LibraryBooksStatus.success,
        books: merged,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.books.isEmpty
            ? LibraryBooksStatus.failure
            : LibraryBooksStatus.success,
        error: e.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }
}
