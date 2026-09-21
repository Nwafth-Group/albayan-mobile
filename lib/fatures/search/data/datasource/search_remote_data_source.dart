
// ============================================
// FILE: lib/fatures/search/data/datasource/search_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/advanced_search_filter.dart';
import '../models/search_initial_model.dart';
import '../models/search_results_response.dart';

abstract class SearchRemoteDataSource {
  /// GET /public/search/initial
  Future<SearchInitialModel> getInitial();

  /// GET /public/search?q=&authors[]=&content_types[]=&...
  Future<SearchResultsResponse> search({
    required AdvancedSearchFilter filter,
    required int page,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiService _api;

  SearchRemoteDataSourceImpl(this._api);

  @override
  Future<SearchInitialModel> getInitial() async {
    final response = await _api.get(ApiConstants.searchInitial);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return SearchInitialModel.fromJson(data);
    }
    return SearchInitialModel.empty;
  }

  @override
  Future<SearchResultsResponse> search({
    required AdvancedSearchFilter filter,
    required int page,
  }) async {
    final response = await _api.get(
      ApiConstants.search,
      queryParameters: filter.toQuery(page: page),
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return SearchResultsResponse.fromData(data);
    }
    return SearchResultsResponse.fromData(const {});
  }
}
