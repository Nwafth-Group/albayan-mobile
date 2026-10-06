// ============================================
// FILE: lib/fatures/settings/data/datasource/company_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/company_info_model.dart';

abstract class CompanyRemoteDataSource {
  /// GET /public/company-info
  Future<CompanyInfoModel> getCompanyInfo();

  /// POST /public/contact-us — body `{ name, email, subject, message }`.
  Future<void> sendContactMessage({
    required String name,
    required String email,
    required ContactSubject subject,
    required String message,
  });
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final ApiService _api;

  CompanyRemoteDataSourceImpl(this._api);

  @override
  Future<CompanyInfoModel> getCompanyInfo() async {
    final response = await _api.get(ApiConstants.companyInfo);
    final data = response['data'];
    if (data is Map<String, dynamic>) return CompanyInfoModel.fromJson(data);
    throw AppStrings.errorInvalidResponse.tr();
  }

  @override
  Future<void> sendContactMessage({
    required String name,
    required String email,
    required ContactSubject subject,
    required String message,
  }) async {
    await _api.post(
      ApiConstants.contactUs,
      data: {
        'name': name,
        'email': email,
        'subject': subject.apiValue,
        'message': message,
      },
    );
  }
}

/// Company info rarely changes, and several screens need it (About, Contact,
/// later the gift message and VAT) — so it's fetched once per app session
/// and shared. A failed fetch isn't cached, so the next caller retries.
class CompanyInfoStore {
  CompanyInfoStore._();

  static Future<CompanyInfoModel>? _cache;

  static Future<CompanyInfoModel> get({
    CompanyRemoteDataSource? dataSource,
    bool forceRefresh = false,
  }) {
    if (forceRefresh) _cache = null;
    return _cache ??= (dataSource ?? CompanyRemoteDataSourceImpl(ApiService()))
        .getCompanyInfo()
        .catchError((Object e) {
          _cache = null;
          throw e;
        });
  }
}
