// ============================================
// FILE: lib/fatures/home/data/datasource/home_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';

import '../models/home_section_model.dart';

abstract class HomeRemoteDataSource {
  /// GET <endpoint> — one home section's content, e.g.
  /// `ApiConstants.homeSectionBanners`.
  Future<HomeSectionModel> getSection(String endpoint);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiService _api;

  HomeRemoteDataSourceImpl(this._api);

  @override
  Future<HomeSectionModel> getSection(String endpoint) async {
    final response = await _api.get(endpoint);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return HomeSectionModel.fromJson(data);
    }
    return HomeSectionModel(meta: HomeSectionMeta.empty);
  }
}
