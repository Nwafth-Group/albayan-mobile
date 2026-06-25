
// ============================================
// FILE: lib/fatures/articles/data/datasource/articles_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/article_model.dart';
import '../models/comment_model.dart';
import '../models/similar_articles_response.dart';

abstract class ArticlesRemoteDataSource {
  Future<ArticleModel> getArticle(String id);

  Future<CommentsResponse> getComments({required String id, required int page});

  Future<SimilarArticlesResponse> getSimilar({
    required String id,
    required int page,
  });

  /// Submit a rating + optional comment for the article.
  /// NOTE: endpoint path is assumed RESTful (POST .../comments). Adjust if the
  /// backend uses a different route.
  Future<void> submitRating({
    required String id,
    required double rating,
    String? comment,
  });
}

class ArticlesRemoteDataSourceImpl implements ArticlesRemoteDataSource {
  final ApiService _api;

  ArticlesRemoteDataSourceImpl(this._api);

  @override
  Future<ArticleModel> getArticle(String id) async {
    final response = await _api.get('${ApiConstants.articles}/$id');
    final data = response['data'];
    if (data is Map<String, dynamic>) return ArticleModel.fromJson(data);
    throw Exception('Invalid article response');
  }

  @override
  Future<CommentsResponse> getComments({
    required String id,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.articles}/$id/comments',
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) return CommentsResponse.fromData(data);
    return CommentsResponse.fromData(const {});
  }

  @override
  Future<SimilarArticlesResponse> getSimilar({
    required String id,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.articles}/$id/similar',
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return SimilarArticlesResponse.fromData(data);
    }
    return SimilarArticlesResponse.fromData(const {});
  }

  @override
  Future<void> submitRating({
    required String id,
    required double rating,
    String? comment,
  }) async {
    await _api.post(
      '${ApiConstants.articles}/$id/comments',
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment_text': comment.trim(),
      },
    );
  }
}