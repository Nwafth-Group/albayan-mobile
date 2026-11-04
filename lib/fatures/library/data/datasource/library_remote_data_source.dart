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

  /// GET /reader/personal-categories
  Future<List<PersonalCategoryModel>> getPersonalCategories();

  /// GET /reader/personal-categories/{id}/items?type=&page=
  Future<PersonalCategoryItemsResponse> getPersonalCategoryItems(
    String categoryId, {
    required PersonalCategoryType type,
    required int page,
  });

  /// POST /reader/personal-categories  body: { "name" }
  Future<PersonalCategoryModel> createPersonalCategory(String name);

  /// DELETE /reader/personal-categories/{id}
  Future<void> deletePersonalCategory(String categoryId);

  /// POST /reader/personal-categories/{id}/toggle-item
  /// body: { "item_id", "type": "book|issue|article" }
  /// Adds the item to the category, or removes it if it's already there.
  Future<void> toggleCategoryItem(
    String categoryId, {
    required PersonalCategoryType type,
    required String itemId,
  });

  /// POST /reader/my-library/toggle  body: { "type": "book|issue|article", "id" }
  /// Toggles the item in/out of My Library. Returns whether it's in the
  /// library afterwards when the API says so, otherwise null.
  Future<bool?> toggleLibraryItem({required String type, required String id});
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
  Future<List<PersonalCategoryModel>> getPersonalCategories() async {
    final response = await _api.get(ApiConstants.personalCategories);
    return PersonalCategoryModel.listFrom(response['data']);
  }

  @override
  Future<PersonalCategoryItemsResponse> getPersonalCategoryItems(
    String categoryId, {
    required PersonalCategoryType type,
    required int page,
  }) async {
    final response = await _api.get(
      ApiConstants.personalCategoryItems(categoryId),
      queryParameters: {'type': type.value, 'page': page},
    );
    return PersonalCategoryItemsResponse.fromData(response['data'], type);
  }

  @override
  Future<PersonalCategoryModel> createPersonalCategory(String name) async {
    final response = await _api.post(
      ApiConstants.personalCategories,
      data: {'name': name},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return PersonalCategoryModel.fromJson(data);
    }
    return PersonalCategoryModel(id: '', name: name);
  }

  @override
  Future<void> deletePersonalCategory(String categoryId) async {
    await _api.delete(ApiConstants.personalCategory(categoryId));
  }

  @override
  Future<void> toggleCategoryItem(
    String categoryId, {
    required PersonalCategoryType type,
    required String itemId,
  }) async {
    await _api.post(
      ApiConstants.personalCategoryToggleItem(categoryId),
      data: {'item_id': itemId, 'type': type.value},
    );
  }

  @override
  Future<bool?> toggleLibraryItem({
    required String type,
    required String id,
  }) async {
    final response = await _api.post(
      ApiConstants.myLibraryToggle,
      data: {'type': type, 'id': id},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      for (final key in const [
        'in_library',
        'is_in_library',
        'is_added',
        'added',
        'is_owned',
        'attached',
      ]) {
        final v = data[key];
        if (v is bool) return v;
      }
    }
    return null;
  }
}
