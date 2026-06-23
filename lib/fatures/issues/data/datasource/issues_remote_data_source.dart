// ============================================
// FILE: lib/fatures/issues/data/datasource/issues_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/widgets/issues_filter.dart';

import '../models/issue_detail_model.dart';
import '../models/issues_response.dart';

abstract class IssuesRemoteDataSource {
  Future<IssuesResponse> getIssues({
    required IssuesFilter filter,
    required int page,
  });

  Future<IssueDetailModel> getIssueDetails(String id);
}

class IssuesRemoteDataSourceImpl implements IssuesRemoteDataSource {
  final ApiService _api;

  IssuesRemoteDataSourceImpl(this._api);

  @override
  Future<IssuesResponse> getIssues({
    required IssuesFilter filter,
    required int page,
  }) async {
    final response = await _api.get(
      ApiConstants.issues,
      queryParameters: filter.toQuery(page: page),
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return IssuesResponse.fromData(data);
    }
    return IssuesResponse.fromData(const {});
  }

  @override
  Future<IssueDetailModel> getIssueDetails(String id) async {
    final response = await _api.get('${ApiConstants.issues}/$id');

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return IssueDetailModel.fromJson(data);
    }
    throw Exception('Invalid issue details response');
  }
}