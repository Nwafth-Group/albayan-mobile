
// ============================================
// FILE: lib/fatures/corners/data/datasource/corners_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/corner_articles_filter.dart';
import '../models/corner_articles_response.dart';
import '../models/corner_model.dart';

abstract class CornersRemoteDataSource {
  /// GET /public/corners/{id}
  Future<CornerModel> getCorner(String id);

  /// GET /public/corners/{id}/articles
  Future<CornerArticlesResponse> getCornerArticles({
    required String id,
    required CornerArticlesFilter filter,
    required int page,
  });
}

class CornersRemoteDataSourceImpl implements CornersRemoteDataSource {
  final ApiService _api;

  CornersRemoteDataSourceImpl(this._api);

  @override
  Future<CornerModel> getCorner(String id) async {
    final response = await _api.get('${ApiConstants.corners}/$id');

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return CornerModel.fromJson(data);
    }
    throw Exception('Invalid corner response');
  }

  @override
  Future<CornerArticlesResponse> getCornerArticles({
    required String id,
    required CornerArticlesFilter filter,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.corners}/$id/articles',
      queryParameters: filter.toQuery(page: page),
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return CornerArticlesResponse.fromData(data);
    }
    return CornerArticlesResponse.fromData(const {});
  }
}