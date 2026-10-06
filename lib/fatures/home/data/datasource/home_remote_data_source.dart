// ============================================
// FILE: lib/fatures/home/data/datasource/home_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/home_section_model.dart';

abstract class HomeRemoteDataSource {
  /// GET /public/home-sections — the ordered list of sections to show.
  Future<List<HomeSectionRef>> getSectionList();

  /// GET one section's content (`HomeSectionRef.endpoint`).
  Future<HomeSectionModel> getSection(String endpoint);

  /// The first section of [type] (e.g. `ad_banner`), or null if the home
  /// page has none.
  Future<HomeSectionModel?> getFirstSectionOfType(String type);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiService _api;

  HomeRemoteDataSourceImpl(this._api);

  @override
  Future<List<HomeSectionRef>> getSectionList() async {
    final response = await _api.get(ApiConstants.homeSections);
    final data = response['data'];
    final items = data is Map<String, dynamic> ? data['items'] : data;
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(HomeSectionRef.fromJson)
        .where((r) => r.id.isNotEmpty)
        .toList();
  }

  @override
  Future<HomeSectionModel> getSection(String endpoint) async {
    final response = await _api.get(endpoint);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return HomeSectionModel.fromJson(data);
    }
    return HomeSectionModel(meta: HomeSectionMeta.empty);
  }

  @override
  Future<HomeSectionModel?> getFirstSectionOfType(String type) async {
    final refs = await getSectionList();
    for (final ref in refs) {
      if (ref.type == type) return getSection(ref.endpoint);
    }
    return null;
  }
}
