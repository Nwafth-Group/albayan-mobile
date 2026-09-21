
// ============================================
// FILE: lib/fatures/library/data/datasource/library_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/library_article_model.dart';
import '../models/library_book_model.dart';
import '../models/library_issue_model.dart';
import '../models/library_summary_model.dart';
import '../models/personal_category_model.dart';

abstract class LibraryRemoteDataSource {
  /// GET /reader/my-library
  Future<LibrarySummaryModel> getSummary();

  /// GET /reader/my-library/books?page=
  Future<LibraryBooksResponse> getBooks({required int page});

  /// GET /reader/my-library/magazine/issues?page=
  Future<LibraryIssuesResponse> getMagazineIssues({required int page});

  /// GET /reader/my-library/magazine/articles?page=
  Future<LibraryArticlesResponse> getMagazineArticles({required int page});

  /// GET /reader/personal-categories/counts
  Future<PersonalCategoryCounts> getPersonalCategoryCounts();

  /// GET /reader/personal-categories?type=
  Future<List<PersonalCategoryModel>> getPersonalCategories(
    PersonalCategoryType type,
  );
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final ApiService _api;

  LibraryRemoteDataSourceImpl(this._api);

  @override
  Future<LibrarySummaryModel> getSummary() async {
    final response = await _api.get(ApiConstants.myLibrary);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return LibrarySummaryModel.fromJson(data);
    }
    return LibrarySummaryModel.empty;
  }

  @override
  Future<LibraryBooksResponse> getBooks({required int page}) async {
    final response = await _api.get(
      ApiConstants.myLibraryBooks,
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return LibraryBooksResponse.fromData(data);
    }
    return LibraryBooksResponse.fromData(const {});
  }

  @override
  Future<LibraryIssuesResponse> getMagazineIssues({required int page}) async {
    final response = await _api.get(
      ApiConstants.myLibraryMagazineIssues,
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return LibraryIssuesResponse.fromData(data);
    }
    return LibraryIssuesResponse.fromData(const {});
  }

  @override
  Future<LibraryArticlesResponse> getMagazineArticles({
    required int page,
  }) async {
    final response = await _api.get(
      ApiConstants.myLibraryMagazineArticles,
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return LibraryArticlesResponse.fromData(data);
    }
    return LibraryArticlesResponse.fromData(const {});
  }

  @override
  Future<PersonalCategoryCounts> getPersonalCategoryCounts() async {
    final response = await _api.get(ApiConstants.personalCategoriesCounts);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return PersonalCategoryCounts.fromJson(data);
    }
    return PersonalCategoryCounts.empty;
  }

  @override
  Future<List<PersonalCategoryModel>> getPersonalCategories(
    PersonalCategoryType type,
  ) async {
    final response = await _api.get(
      ApiConstants.personalCategories,
      queryParameters: {'type': type.value},
    );
    return PersonalCategoryModel.listFrom(response['data']);
  }
}
