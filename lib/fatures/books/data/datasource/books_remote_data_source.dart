
// ============================================
// FILE: lib/fatures/books/data/datasource/books_remote_data_source.dart
// ============================================

import 'package:albayan/fatures/articles/data/models/comment_model.dart';
import 'package:albayan/fatures/authors/data/models/book_model.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/book_detail_model.dart';
import '../models/books_filter.dart';

abstract class BooksRemoteDataSource {
  /// GET /public/books?per_page=15&search=
  Future<BooksResponse> getBooks({
    required BooksFilter filter,
    required int page,
  });

  /// GET /public/books/{id}
  Future<BookDetailModel> getBook(String id);

  /// GET /public/books/{id}/comments?per_page=15
  Future<CommentsResponse> getComments({
    required String id,
    required int page,
  });

  /// GET /public/books/{id}/related
  Future<BooksResponse> getRelated({required String id, required int page});

  /// Submit a rating + optional comment for the book.
  /// NOTE: endpoint path is assumed RESTful (POST .../comments), matching
  /// the articles feature convention. Adjust if the backend differs.
  Future<void> submitRating({
    required String id,
    required double rating,
    String? comment,
  });
}

class BooksRemoteDataSourceImpl implements BooksRemoteDataSource {
  final ApiService _api;

  BooksRemoteDataSourceImpl(this._api);

  @override
  Future<BooksResponse> getBooks({
    required BooksFilter filter,
    required int page,
  }) async {
    final response = await _api.get(
      ApiConstants.books,
      queryParameters: filter.toQuery(page: page),
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return BooksResponse.fromData(data);
    }
    return BooksResponse.fromData(const {});
  }

  @override
  Future<BookDetailModel> getBook(String id) async {
    final response = await _api.get('${ApiConstants.books}/$id');
    final data = response['data'];
    if (data is Map<String, dynamic>) return BookDetailModel.fromJson(data);
    throw Exception('Invalid book response');
  }

  @override
  Future<CommentsResponse> getComments({
    required String id,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.books}/$id/comments',
      queryParameters: {'page': page, 'per_page': 15},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) return CommentsResponse.fromData(data);
    return CommentsResponse.fromData(const {});
  }

  @override
  Future<BooksResponse> getRelated({
    required String id,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.books}/$id/related',
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) return BooksResponse.fromData(data);
    return BooksResponse.fromData(const {});
  }

  @override
  Future<void> submitRating({
    required String id,
    required double rating,
    String? comment,
  }) async {
    await _api.post(
      '${ApiConstants.books}/$id/comments',
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment_text': comment.trim(),
      },
    );
  }
}
