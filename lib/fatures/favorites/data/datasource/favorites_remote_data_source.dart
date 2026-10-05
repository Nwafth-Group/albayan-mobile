
// ============================================
// FILE: lib/fatures/favorites/data/datasource/favorites_remote_data_source.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/favorite_item_model.dart';

abstract class FavoritesRemoteDataSource {
  /// POST /reader/favorites/toggle — body `{ "type", "id" }`.
  /// Returns the item's new state (`data.is_favorite`).
  Future<bool> toggle({required FavoriteType type, required String id});

  /// GET /reader/favorites?page=
  Future<FavoritesResponse> getFavorites({required int page});
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiService _api;

  FavoritesRemoteDataSourceImpl(this._api);

  @override
  Future<bool> toggle({required FavoriteType type, required String id}) async {
    final response = await _api.post(
      ApiConstants.favoritesToggle,
      data: {'type': type.apiValue, 'id': id},
    );
    final data = response['data'];
    if (data is Map<String, dynamic> && data['is_favorite'] is bool) {
      return data['is_favorite'] as bool;
    }
    throw AppStrings.errorInvalidResponse.tr();
  }

  @override
  Future<FavoritesResponse> getFavorites({required int page}) async {
    final response = await _api.get(
      ApiConstants.favorites,
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return FavoritesResponse.fromData(data);
    }
    return FavoritesResponse.fromData(const {});
  }
}
