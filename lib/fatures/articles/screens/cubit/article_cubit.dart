
// ============================================
// FILE: lib/fatures/articles/screens/cubit/article_cubit.dart
// ============================================

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/articles_remote_data_source.dart';
import '../../data/models/article_model.dart';
import '../../data/models/comment_model.dart';

part 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticlesRemoteDataSource dataSource;
  final String articleId;

  bool _fetchingComments = false;
  bool _fetchingSimilar = false;

  ArticleCubit(this.dataSource, {required this.articleId})
      : super(const ArticleState());

  /// Loads the article detail, then the first page of comments and similar.
  Future<void> load() async {
    emit(state.copyWith(status: ArticleStatus.loading, error: null));
    try {
      final article = await dataSource.getArticle(articleId);
      emit(state.copyWith(status: ArticleStatus.success, article: article));
      // Fire the two lists in parallel.
      await Future.wait([
        _fetchComments(page: 1, reset: true),
        _fetchSimilar(page: 1, reset: true),
      ]);
    } catch (e) {
      emit(state.copyWith(status: ArticleStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadMoreComments() async {
    if (_fetchingComments || !state.commentsHasMore) return;
    final next = (state.commentsMeta?.currentPage ?? 1) + 1;
    await _fetchComments(page: next, reset: false);
  }

  Future<void> loadMoreSimilar() async {
    if (_fetchingSimilar || !state.similarHasMore) return;
    final next = (state.similarMeta?.currentPage ?? 1) + 1;
    await _fetchSimilar(page: next, reset: false);
  }

  /// Optimistic favorite toggle (wire the real endpoint here when available).
  void toggleFavorite() {
    final a = state.article;
    if (a == null) return;
    emit(state.copyWith(article: a.copyWith(isFavorite: !a.isFavorite)));
    // TODO: call favorite/unfavorite endpoint; revert on failure.
  }

  /// Submits a rating + optional comment, then refreshes the comments list.
  Future<bool> submitRating({required double rating, String? comment}) async {
    if (state.submittingRating) return false;
    emit(state.copyWith(submittingRating: true));
    try {
      await dataSource.submitRating(
        id: articleId,
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
      commentsStatus:
      reset ? ListStatus.loading : ListStatus.loadingMore,
    ));
    try {
      final res = await dataSource.getComments(id: articleId, page: page);
      final merged = reset ? res.items : [...state.comments, ...res.items];
      emit(state.copyWith(
        commentsStatus:
        merged.isEmpty ? ListStatus.empty : ListStatus.success,
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

  Future<void> _fetchSimilar({required int page, required bool reset}) async {
    if (_fetchingSimilar) return;
    _fetchingSimilar = true;
    emit(state.copyWith(
      similarStatus: reset ? ListStatus.loading : ListStatus.loadingMore,
    ));
    try {
      final res = await dataSource.getSimilar(id: articleId, page: page);
      final merged = reset ? res.items : [...state.similar, ...res.items];
      emit(state.copyWith(
        similarStatus:
        merged.isEmpty ? ListStatus.empty : ListStatus.success,
        similar: merged,
        similarMeta: res.meta,
      ));
    } catch (_) {
      emit(state.copyWith(
        similarStatus:
        state.similar.isEmpty ? ListStatus.failure : ListStatus.success,
      ));
    } finally {
      _fetchingSimilar = false;
    }
  }
}