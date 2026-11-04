// ============================================
// FILE: lib/fatures/settings/data/datasource/subscription_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionRemoteDataSource {
  /// GET /public/subscriptions/plans
  Future<List<SubscriptionPlanModel>> getPlans({required String languageCode});

  /// GET /reader/subscriptions/current — null when the reader has none.
  Future<UserSubscriptionModel?> getCurrent({required String languageCode});

  /// GET /reader/subscriptions/history?page=
  Future<({List<UserSubscriptionModel> items, PaginationMeta meta})>
  getHistory({required int page, required String languageCode});

  /// POST /reader/subscriptions/purchase
  Future<UserSubscriptionModel> purchase({
    required String planId,
    required String platform,
    required String languageCode,
    String? providerTransactionId,
    String? originalTransactionId,
    String? receiptData,
  });
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiService _api;

  SubscriptionRemoteDataSourceImpl(this._api);

  @override
  Future<List<SubscriptionPlanModel>> getPlans({
    required String languageCode,
  }) async {
    final response = await _api.get(ApiConstants.subscriptionPlans);
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => SubscriptionPlanModel.fromJson(j, languageCode: languageCode))
        .toList();
  }

  @override
  Future<UserSubscriptionModel?> getCurrent({
    required String languageCode,
  }) async {
    final Response response;
    try {
      // A reader without a subscription may get a 404 instead of
      // `data: null` — both mean "no current subscription".
      response = await _api.dio.get(
        ApiConstants.currentSubscription,
        options: Options(
          validateStatus: (s) => s != null && (s < 300 || s == 404),
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message']?.toString() : null;
      throw (message != null && message.trim().isNotEmpty)
          ? message
          : AppStrings.somethingWentWrong.tr();
    }
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    return data is Map<String, dynamic> && data.isNotEmpty
        ? UserSubscriptionModel.fromJson(data, languageCode: languageCode)
        : null;
  }

  @override
  Future<({List<UserSubscriptionModel> items, PaginationMeta meta})>
  getHistory({required int page, required String languageCode}) async {
    final response = await _api.get(
      ApiConstants.subscriptionHistory,
      queryParameters: {'page': page},
    );
    final data = response['data'];

    // Accept both a bare list and a paginated `{items, meta}` envelope.
    final rawItems = data is List
        ? data
        : data is Map
        ? (data['items'] ?? data['data'])
        : null;
    final rawMeta = data is Map ? data['meta'] : response['meta'];

    return (
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(
                  (j) => UserSubscriptionModel.fromJson(
                    j,
                    languageCode: languageCode,
                  ),
                )
                .toList()
          : const <UserSubscriptionModel>[],
      meta: rawMeta is Map<String, dynamic>
          ? PaginationMeta.fromJson(rawMeta)
          : PaginationMeta.empty,
    );
  }

  @override
  Future<UserSubscriptionModel> purchase({
    required String planId,
    required String platform,
    required String languageCode,
    String? providerTransactionId,
    String? originalTransactionId,
    String? receiptData,
  }) async {
    final response = await _api.post(
      ApiConstants.purchaseSubscription,
      data: {
        'plan_id': planId,
        'platform': platform,
        'provider_transaction_id': ?providerTransactionId,
        'original_transaction_id': ?originalTransactionId,
        'receipt_data': ?receiptData,
      },
    );
    final data = response['data'];
    return UserSubscriptionModel.fromJson(
      data is Map<String, dynamic> ? data : const {},
      languageCode: languageCode,
    );
  }
}
