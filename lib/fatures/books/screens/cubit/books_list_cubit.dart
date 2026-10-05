
// ============================================
// FILE: lib/fatures/books/screens/cubit/books_list_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authors/data/models/book_model.dart';
import '../../../favorites/data/favorites_sync.dart';
import '../../../favorites/data/models/favorite_item_model.dart';
import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/books_remote_data_source.dart';
import '../../data/models/books_filter.dart';

part 'books_list_state.dart';

class BooksListCubit extends Cubit<BooksListState> {
  final BooksRemoteDataSource dataSource;

  BooksListCubit(this.dataSource) : super(const BooksListState()) {
    // Keep favorite flags in sync when a book is (un)favorited elsewhere.
    _favoriteSub = FavoritesSync.changes.listen((c) {
      if (c.type == FavoriteType.book) _setFavorite(c.id, c.isFavorite);
    });
  }

  Timer? _searchDebounce;
  bool _isFetching = false;
  late final StreamSubscription<FavoriteChange> _favoriteSub;

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

  /// Debounced free-text search.
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      emit(state.copyWith(filter: state.filter.setSearch(query)));
      _fetch(page: 1, reset: true);
    });
  }

  /// POST /reader/favorites/toggle — optimistic, settles on the server's
  /// answer. [bookId] is the list item's `id`, i.e. the version id
  /// favorites use.
  Future<void> toggleFavorite(String bookId) async {
    final book = state.books.where((b) => b.id == bookId).firstOrNull;
    if (book == null) return;
    await FavoritesSync.toggleOptimistic(
      type: FavoriteType.book,
      id: bookId,
      current: book.isFavorite,
      apply: (isFavorite) => _setFavorite(bookId, isFavorite),
    );
  }

  void _setFavorite(String bookId, bool isFavorite) {
    if (isClosed) return;
    var changed = false;
    final updated = state.books.map((b) {
      if (b.id != bookId || b.isFavorite == isFavorite) return b;
      changed = true;
      return b.copyWith(isFavorite: isFavorite);
    }).toList();
    if (changed) emit(state.copyWith(books: updated));
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(state.copyWith(
      status: reset ? BooksListStatus.loading : BooksListStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getBooks(
        filter: state.filter,
        page: page,
      );

      final merged = reset ? result.items : [...state.books, ...result.items];

      emit(state.copyWith(
        status:
            merged.isEmpty ? BooksListStatus.empty : BooksListStatus.success,
        books: merged,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.books.isEmpty
            ? BooksListStatus.failure
            : BooksListStatus.success,
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
