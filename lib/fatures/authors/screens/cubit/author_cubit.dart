
// ============================================
// FILE: lib/fatures/authors/screens/cubit/author_cubit.dart
// ============================================

import 'dart:async';

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import 'package:albayan/fatures/favorites/data/favorites_sync.dart';
import 'package:albayan/fatures/favorites/data/models/favorite_item_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/authors_remote_data_source.dart';
import '../../data/models/author_details_model.dart';
import '../../data/models/book_model.dart';

part 'author_state.dart';

class AuthorCubit extends Cubit<AuthorState> {
  final AuthorsRemoteDataSource dataSource;
  final String authorId;

  bool _fetchingArticles = false;
  bool _fetchingBooks = false;

  late final StreamSubscription<FavoriteChange> _favoriteSub;

  AuthorCubit(this.dataSource, {required this.authorId})
      : super(const AuthorState()) {
    // Keep the books tab's hearts in sync with changes made elsewhere.
    _favoriteSub = FavoritesSync.changes.listen((c) {
      if (c.type == FavoriteType.book) _setBookFavorite(c.id, c.isFavorite);
    });
  }

  @override
  Future<void> close() {
    _favoriteSub.cancel();
    return super.close();
  }

  /// POST /reader/favorites/toggle for one of this author's books —
  /// optimistic, settles on the server's answer. [bookId] is the book's
  /// list `id` (its version id, which favorites use).
  Future<void> toggleBookFavorite(String bookId) async {
    final book = state.books.where((b) => b.id == bookId).firstOrNull;
    if (book == null) return;
    await FavoritesSync.toggleOptimistic(
      type: FavoriteType.book,
      id: bookId,
      current: book.isFavorite,
      apply: (isFavorite) => _setBookFavorite(bookId, isFavorite),
    );
  }

  void _setBookFavorite(String bookId, bool isFavorite) {
    if (isClosed) return;
    var changed = false;
    final updated = state.books.map((b) {
      if (b.id != bookId || b.isFavorite == isFavorite) return b;
      changed = true;
      return b.copyWith(isFavorite: isFavorite);
    }).toList();
    if (changed) emit(state.copyWith(books: updated));
  }

  Future<void> load() async {
    emit(state.copyWith(status: AuthorStatus.loading, error: null));
    try {
      final author = await dataSource.getAuthor(authorId);
      emit(state.copyWith(status: AuthorStatus.success, author: author));
      await Future.wait([
        _fetchArticles(page: 1, reset: true, year: null),
        _fetchBooks(page: 1, reset: true),
      ]);
    } catch (e) {
      emit(state.copyWith(status: AuthorStatus.failure, error: e.toString()));
    }
  }

  Future<void> selectYear(int year) async {
    if (year == state.selectedYear) return;
    emit(state.copyWith(selectedYear: year));
    await _fetchArticles(page: 1, reset: true, year: year);
  }

  Future<void> loadMoreArticles() async {
    if (_fetchingArticles || !state.articlesHasMore) return;
    final next = (state.articlesMeta?.currentPage ?? 1) + 1;
    await _fetchArticles(page: next, reset: false, year: state.selectedYear);
  }

  Future<void> loadMoreBooks() async {
    if (_fetchingBooks || !state.booksHasMore) return;
    final next = (state.booksMeta?.currentPage ?? 1) + 1;
    await _fetchBooks(page: next, reset: false);
  }

  Future<void> _fetchArticles({
    required int page,
    required bool reset,
    required int? year,
  }) async {
    if (_fetchingArticles) return;
    _fetchingArticles = true;
    emit(state.copyWith(
      articlesStatus: reset ? ListStatus.loading : ListStatus.loadingMore,
    ));
    try {
      final res = await dataSource.getArticles(
        id: authorId,
        year: year,
        page: page,
      );
      final merged = reset ? res.items : [...state.articles, ...res.items];
      emit(state.copyWith(
        articlesStatus:
        merged.isEmpty ? ListStatus.empty : ListStatus.success,
        articles: merged,
        articlesMeta: res.meta,
        years: res.years.isNotEmpty ? res.years : state.years,
        selectedYear: state.selectedYear ?? res.selectedYear,
      ));
    } catch (_) {
      emit(state.copyWith(
        articlesStatus:
        state.articles.isEmpty ? ListStatus.failure : ListStatus.success,
      ));
    } finally {
      _fetchingArticles = false;
    }
  }

  Future<void> _fetchBooks({required int page, required bool reset}) async {
    if (_fetchingBooks) return;
    _fetchingBooks = true;
    emit(state.copyWith(
      booksStatus: reset ? ListStatus.loading : ListStatus.loadingMore,
    ));
    try {
      final res = await dataSource.getBooks(id: authorId, page: page);
      final merged = reset ? res.items : [...state.books, ...res.items];
      emit(state.copyWith(
        booksStatus: merged.isEmpty ? ListStatus.empty : ListStatus.success,
        books: merged,
        booksMeta: res.meta,
      ));
    } catch (_) {
      emit(state.copyWith(
        booksStatus:
        state.books.isEmpty ? ListStatus.failure : ListStatus.success,
      ));
    } finally {
      _fetchingBooks = false;
    }
  }
}