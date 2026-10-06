// ============================================
// FILE: lib/fatures/settings/data/datasource/settings_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/policy_model.dart';

abstract class SettingsRemoteDataSource {
  /// GET /public/policies?policy_type=terms|privacy|financial
  /// Returns null when the backend has no policy of that type.
  Future<PolicyModel?> getPolicy(PolicyType type);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiService _api;

  SettingsRemoteDataSourceImpl(this._api);

  @override
  Future<PolicyModel?> getPolicy(PolicyType type) async {
    final response = await _api.get(
      ApiConstants.policies,
      queryParameters: {'policy_type': type.apiValue},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return PolicyModel.fromJson(data, type);
    }
    return null;
  }
}
