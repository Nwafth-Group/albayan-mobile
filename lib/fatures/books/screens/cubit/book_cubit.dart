
// ============================================
// FILE: lib/fatures/books/screens/cubit/book_cubit.dart
// ============================================

import 'dart:async';

import 'package:albayan/fatures/articles/data/models/comment_model.dart';
import 'package:albayan/fatures/authors/data/models/book_model.dart';
import 'package:albayan/fatures/favorites/data/favorites_sync.dart';
import 'package:albayan/fatures/favorites/data/models/favorite_item_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/books_remote_data_source.dart';
import '../../data/models/book_detail_model.dart';

part 'book_state.dart';

class BookCubit extends Cubit<BookState> {
  final BooksRemoteDataSource dataSource;
  final String bookId;

  bool _fetchingComments = false;
  bool _fetchingRelated = false;

  late final StreamSubscription<FavoriteChange> _favoriteSub;

  BookCubit(this.dataSource, {required this.bookId})
      : super(const BookState()) {
    // Keep the heart in sync when this book is (un)favorited elsewhere.
    _favoriteSub = FavoritesSync.changes.listen((c) {
      final b = state.book;
      if (b != null && c.matches(FavoriteType.book, _favoriteId(b))) {
        _setFavorite(c.isFavorite);
      }
    });
  }

  @override
  Future<void> close() {
    _favoriteSub.cancel();
    return super.close();
  }

  /// Favorites identify a book by its version id (the same id the favorites
  /// list returns), not the parent book id.
  String _favoriteId(BookDetailModel b) =>
      b.version.id.isNotEmpty ? b.version.id : b.id;

  /// Loads the book detail, then the first page of comments and related books.
  Future<void> load() async {
    emit(state.copyWith(status: BookStatus.loading, error: null));
    try {
      final book = await dataSource.getBook(bookId);
      emit(state.copyWith(status: BookStatus.success, book: book));
      // Fire the two lists in parallel.
      await Future.wait([
        _fetchComments(page: 1, reset: true),
        _fetchRelated(page: 1, reset: true),
      ]);
    } catch (e) {
      emit(state.copyWith(status: BookStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadMoreComments() async {
    if (_fetchingComments || !state.commentsHasMore) return;
    final next = (state.commentsMeta?.currentPage ?? 1) + 1;
    await _fetchComments(page: next, reset: false);
  }

  Future<void> loadMoreRelated() async {
    if (_fetchingRelated || !state.relatedHasMore) return;
    final next = (state.relatedMeta?.currentPage ?? 1) + 1;
    await _fetchRelated(page: next, reset: false);
  }

  /// POST /reader/favorites/toggle — optimistic, settles on the server's
  /// answer (see [FavoritesSync.toggleOptimistic]).
  Future<void> toggleFavorite() async {
    final b = state.book;
    if (b == null) return;
    await FavoritesSync.toggleOptimistic(
      type: FavoriteType.book,
      id: _favoriteId(b),
      current: b.isFavorite,
      apply: _setFavorite,
    );
  }

  void _setFavorite(bool isFavorite) {
    final b = state.book;
    if (isClosed || b == null || b.isFavorite == isFavorite) return;
    emit(state.copyWith(book: b.copyWith(isFavorite: isFavorite)));
  }

  /// Submits a rating + optional comment, then refreshes the comments list.
  Future<bool> submitRating({required double rating, String? comment}) async {
    if (state.submittingRating) return false;
    emit(state.copyWith(submittingRating: true));
    try {
      await dataSource.submitRating(
        id: bookId,
        rating: rating,
        comment: comment,
      );
      emit(state.copyWith(submittingRating: false));
      await _fetchComments(page: 1, reset: true);
      return true;
    } catch (e) {
      emit(state.copyWith(submittingRating: false));
      return false;
    }
  }

  Future<void> _fetchComments({required int page, required bool reset}) async {
    if (_fetchingComments) return;
    _fetchingComments = true;
    emit(state.copyWith(
      commentsStatus: reset ? ListStatus.loading : ListStatus.loadingMore,
    ));
    try {
      final res = await dataSource.getComments(id: bookId, page: page);
      final merged = reset ? res.items : [...state.comments, ...res.items];
      emit(state.copyWith(
        commentsStatus: merged.isEmpty ? ListStatus.empty : ListStatus.success,
        comments: merged,
        commentsMeta: res.meta,
      ));
    } catch (_) {
      emit(state.copyWith(
        commentsStatus:
            state.comments.isEmpty ? ListStatus.failure : ListStatus.success,
      ));
    } finally {
      _fetchingComments = false;
    }
  }

  Future<void> _fetchRelated({required int page, required bool reset}) async {
    if (_fetchingRelated) return;
    _fetchingRelated = true;
    emit(state.copyWith(
      relatedStatus: reset ? ListStatus.loading : ListStatus.loadingMore,
    ));
    try {
      final res = await dataSource.getRelated(id: bookId, page: page);
      final merged = reset ? res.items : [...state.related, ...res.items];
      emit(state.copyWith(
        relatedStatus: merged.isEmpty ? ListStatus.empty : ListStatus.success,
        related: merged,
        relatedMeta: res.meta,
      ));
    } catch (_) {
      emit(state.copyWith(
        relatedStatus:
            state.related.isEmpty ? ListStatus.failure : ListStatus.success,
      ));
    } finally {
      _fetchingRelated = false;
    }
  }
}
