
// ============================================
// FILE: lib/fatures/offers/data/datasource/offers_remote_data_source.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../../../authors/data/models/book_model.dart';
import '../models/offer_model.dart';

abstract class OffersRemoteDataSource {
  /// GET /public/offers?type=all|package|book|issue|article&search=&page=
  Future<OffersResponse> getOffers({
    required String type,
    String search = '',
    int page = 1,
  });

  /// GET /public/offers/{offerId} — takes an offer id (e.g. the urgent
  /// offer's), not a list item's id.
  Future<OfferDetailsModel> getOfferDetails(String offerId);

  /// GET /public/packages/{packageId} — the books inside a package.
  Future<List<BookModel>> getPackageItems(String packageId);
}

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  final ApiService _api;

  OffersRemoteDataSourceImpl(this._api);

  @override
  Future<OffersResponse> getOffers({
    required String type,
    String search = '',
    int page = 1,
  }) async {
    final response = await _api.get(
      ApiConstants.offers,
      queryParameters: {'type': type, 'search': search, 'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return OffersResponse.fromData(data);
    }
    return OffersResponse.fromData(const {});
  }

  @override
  Future<OfferDetailsModel> getOfferDetails(String offerId) async {
    final response = await _api.get('${ApiConstants.offers}/$offerId');
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return OfferDetailsModel.fromJson(data);
    }
    throw AppStrings.errorInvalidResponse.tr();
  }

  @override
  Future<List<BookModel>> getPackageItems(String packageId) async {
    final response = await _api.get('${ApiConstants.packages}/$packageId');
    final data = response['data'];
    final items = data is Map<String, dynamic> ? data['items'] : null;
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromJson)
        .toList();
  }
}
