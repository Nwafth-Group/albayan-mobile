
// ============================================
// FILE: lib/fatures/language/data/datasource/language_remote_datasource.dart
// ============================================

import 'package:albayan/fatures/onboarding/data/language_model.dart';

import '../../../../utils/api_client.dart';
import '../../../../utils/constants.dart';

class LanguageRemoteDataSource {
  final ApiService _api;

  LanguageRemoteDataSource(this._api);

  Future<List<LanguageModel>> getLanguages({String search = ''}) async {
    final response = await _api.get(
      ApiConstants.getLanguages,
      queryParameters: {'search': search},
    );
    final items = response['data']['items'] as List<dynamic>;
    return items
        .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}