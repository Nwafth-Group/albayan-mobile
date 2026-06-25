
// ============================================
// FILE: lib/fatures/authors/data/datasource/authors_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/author_articles_response.dart';
import '../models/author_details_model.dart';
import '../models/book_model.dart';

abstract class AuthorsRemoteDataSource {
  Future<AuthorDetailsModel> getAuthor(String id);

  Future<AuthorArticlesResponse> getArticles({
    required String id,
    int? year,
    required int page,
  });

  Future<BooksResponse> getBooks({required String id, required int page});
}

class AuthorsRemoteDataSourceImpl implements AuthorsRemoteDataSource {
  final ApiService _api;

  AuthorsRemoteDataSourceImpl(this._api);

  @override
  Future<AuthorDetailsModel> getAuthor(String id) async {
    final response = await _api.get('${ApiConstants.authors}/$id');
    final data = response['data'];
    if (data is Map<String, dynamic>) return AuthorDetailsModel.fromJson(data);
    throw Exception('Invalid author response');
  }

  @override
  Future<AuthorArticlesResponse> getArticles({
    required String id,
    int? year,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.authors}/$id/articles',
      queryParameters: {
        'page': page,
        if (year != null) 'year': year,
      },
    );
    return AuthorArticlesResponse.fromResponse(response);
  }

  @override
  Future<BooksResponse> getBooks({
    required String id,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.authors}/$id/books',
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) return BooksResponse.fromData(data);
    return BooksResponse.fromData(const {});
  }
}