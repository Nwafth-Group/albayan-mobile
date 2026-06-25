
// ============================================
// FILE: lib/fatures/articles/screens/cubit/article_state.dart
// ============================================

part of 'article_cubit.dart';

enum ArticleStatus { initial, loading, success, failure }

enum ListStatus { initial, loading, loadingMore, success, empty, failure }

class ArticleState extends Equatable {
  // Detail
  final ArticleStatus status;
  final ArticleModel? article;
  final String? error;

  // Comments / reviews
  final ListStatus commentsStatus;
  final List<CommentModel> comments;
  final PaginationMeta? commentsMeta;

  // Similar
  final ListStatus similarStatus;
  final List<CornerArticleModel> similar;
  final PaginationMeta? similarMeta;

  // Rating submission
  final bool submittingRating;

  const ArticleState({
    this.status = ArticleStatus.initial,
    this.article,
    this.error,
    this.commentsStatus = ListStatus.initial,
    this.comments = const [],
    this.commentsMeta,
    this.similarStatus = ListStatus.initial,
    this.similar = const [],
    this.similarMeta,
    this.submittingRating = false,
  });

  bool get commentsHasMore => commentsMeta?.hasMore ?? false;
  bool get similarHasMore => similarMeta?.hasMore ?? false;

  ArticleState copyWith({
    ArticleStatus? status,
    ArticleModel? article,
    String? error,
    ListStatus? commentsStatus,
    List<CommentModel>? comments,
    PaginationMeta? commentsMeta,
    ListStatus? similarStatus,
    List<CornerArticleModel>? similar,
    PaginationMeta? similarMeta,
    bool? submittingRating,
  }) {
    return ArticleState(
      status: status ?? this.status,
      article: article ?? this.article,
      error: error,
      commentsStatus: commentsStatus ?? this.commentsStatus,
      comments: comments ?? this.comments,
      commentsMeta: commentsMeta ?? this.commentsMeta,
      similarStatus: similarStatus ?? this.similarStatus,
      similar: similar ?? this.similar,
      similarMeta: similarMeta ?? this.similarMeta,
      submittingRating: submittingRating ?? this.submittingRating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    article,
    error,
    commentsStatus,
    comments,
    commentsMeta,
    similarStatus,
    similar,
    similarMeta,
    submittingRating,
  ];
}