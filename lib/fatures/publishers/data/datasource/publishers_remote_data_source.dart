
// ============================================
// FILE: lib/fatures/publishers/data/datasource/publishers_remote_data_source.dart
// ============================================

import 'package:albayan/fatures/authors/data/models/book_model.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/publisher_detail_model.dart';

abstract class PublishersRemoteDataSource {
  /// GET /public/publishers/{id}
  Future<PublisherDetailModel> getPublisher(String id);

  /// GET /public/publishers/{id}/books
  Future<BooksResponse> getBooks({required String id, required int page});
}

class PublishersRemoteDataSourceImpl implements PublishersRemoteDataSource {
  final ApiService _api;

  PublishersRemoteDataSourceImpl(this._api);

  @override
  Future<PublisherDetailModel> getPublisher(String id) async {
    final response = await _api.get('${ApiConstants.publishers}/$id');
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return PublisherDetailModel.fromJson(data);
    }
    throw Exception('Invalid publisher response');
  }

  @override
  Future<BooksResponse> getBooks({
    required String id,
    required int page,
  }) async {
    final response = await _api.get(
      '${ApiConstants.publishers}/$id/books',
      queryParameters: {'page': page},
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) return BooksResponse.fromData(data);
    return BooksResponse.fromData(const {});
  }
}
