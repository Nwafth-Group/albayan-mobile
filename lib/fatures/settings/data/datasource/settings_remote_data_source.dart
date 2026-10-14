// ============================================
// FILE: lib/fatures/settings/data/datasource/settings_remote_data_source.dart
// ============================================

import 'dart:io';

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../cart/data/models/checkout_order_model.dart';
import '../../../issues/data/models/pagination_meta.dart';
import '../models/policy_model.dart';

abstract class SettingsRemoteDataSource {
  /// GET /public/policies?policy_type=terms|privacy|financial
  /// Returns null when the backend has no policy of that type.
  Future<PolicyModel?> getPolicy(PolicyType type);

  /// GET /reader/orders?page= — raw order maps plus pagination; mapped to
  /// `OrderModel` by the cubit (which knows the current language).
  Future<({List<Map<String, dynamic>> items, PaginationMeta meta})> getOrders({
    required int page,
  });

  /// GET /reader/orders/{id} — the raw order map (null if missing).
  Future<Map<String, dynamic>?> getOrder(String id);

  /// GET /reader/orders/{id}/invoice — the invoice's seller/customer/totals
  /// and ZATCA QR payload (no line items; use `getOrder` for those).
  Future<CheckoutInvoice> getInvoice(String orderId);

  /// GET /reader/orders/{id}/invoice/pdf — downloads the invoice PDF into
  /// the app's documents folder and returns the saved file.
  Future<File> downloadInvoicePdf({
    required String orderId,
    required String fileName,
  });
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

  @override
  Future<({List<Map<String, dynamic>> items, PaginationMeta meta})> getOrders({
    required int page,
  }) async {
    final response = await _api.get(
      ApiConstants.orders,
      queryParameters: {'page': page},
    );
    final data = response['data'];
    final map = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    final rawItems = map['items'];
    return (
      items: rawItems is List
          ? rawItems.whereType<Map<String, dynamic>>().toList()
          : const <Map<String, dynamic>>[],
      meta: map['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(map['meta'] as Map<String, dynamic>)
          : PaginationMeta.empty,
    );
  }

  @override
  Future<Map<String, dynamic>?> getOrder(String id) async {
    final response = await _api.get('${ApiConstants.orders}/$id');
    final data = response['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  @override
  Future<CheckoutInvoice> getInvoice(String orderId) async {
    final response = await _api.get(ApiConstants.orderInvoice(orderId));
    final data = response['data'];
    return CheckoutInvoice.fromJson(
      data is Map<String, dynamic> ? data : const {},
    );
  }

  @override
  Future<File> downloadInvoicePdf({
    required String orderId,
    required String fileName,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory('${docs.path}/invoices');
    if (!await folder.exists()) await folder.create(recursive: true);
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final file = File('${folder.path}/$safeName.pdf');

    try {
      // Goes through ApiService's Dio, so the Bearer token is attached.
      await _api.dio.download(
        ApiConstants.orderInvoicePdf(orderId),
        file.path,
        options: Options(headers: {'Accept': 'application/pdf'}),
      );
    } on DioException catch (e) {
      if (await file.exists()) await file.delete();
      throw e.message ?? e.toString();
    }

    // Guard against an error page / JSON body saved as ".pdf".
    final bytes = await file.openRead(0, 4).first;
    if (String.fromCharCodes(bytes) != '%PDF') {
      await file.delete();
      throw 'Invalid invoice file';
    }
    return file;
  }
}
