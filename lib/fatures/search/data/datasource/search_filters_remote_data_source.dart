
// ============================================
// FILE: lib/fatures/search/data/datasource/search_filters_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/category_model.dart';
import '../models/keywords_list_response.dart';

abstract class SearchFiltersRemoteDataSource {
  /// GET /public/categories
  Future<CategoriesListResponse> getCategories({required int page});

  /// GET /public/keywords
  Future<KeywordsListResponse> getKeywords({required int page});
}

class SearchFiltersRemoteDataSourceImpl implements SearchFiltersRemoteDataSource {
  final ApiService _api;

  SearchFiltersRemoteDataSourceImpl(this._api);

  @override
  Future<CategoriesListResponse> getCategories({required int page}) async {
    final response = await _api.get(
      ApiConstants.categories,
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return CategoriesListResponse.fromData(data);
    }
    return CategoriesListResponse.fromData(const {});
  }

  @override
  Future<KeywordsListResponse> getKeywords({required int page}) async {
    final response = await _api.get(
      ApiConstants.keywords,
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return KeywordsListResponse.fromData(data);
    }
    return KeywordsListResponse.fromData(const {});
  }
}
