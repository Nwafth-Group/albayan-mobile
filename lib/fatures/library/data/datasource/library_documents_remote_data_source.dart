// ============================================
// FILE: lib/fatures/library/data/datasource/library_documents_remote_data_source.dart
// ============================================

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../utils/api_client.dart';
import '../../../../utils/constants.dart';
import '../models/personal_document_model.dart';

abstract class LibraryDocumentsRemoteDataSource {
  /// GET /reader/my-library/documents
  Future<List<PersonalDocumentModel>> getDocuments();

  /// POST /reader/my-library/documents (multipart: `files[]` + `title`)
  Future<PersonalDocumentModel> upload({
    required File file,
    required String title,
    void Function(double progress)? onProgress,
  });

  /// DELETE /reader/my-library/documents/{id}
  Future<void> deleteDocument(String id);

  /// GET /reader/my-library/documents/{id}/download — downloads the file
  /// into the app's documents folder and returns the saved file.
  Future<File> downloadDocument({
    required String id,
    required String fileName,
  });
}

class LibraryDocumentsRemoteDataSourceImpl
    implements LibraryDocumentsRemoteDataSource {
  final ApiService _api;

  LibraryDocumentsRemoteDataSourceImpl(this._api);

  @override
  Future<List<PersonalDocumentModel>> getDocuments() async {
    final response = await _api.get(ApiConstants.myLibraryDocuments);
    return PersonalDocumentModel.listFrom(response['data']);
  }

  @override
  Future<PersonalDocumentModel> upload({
    required File file,
    required String title,
    void Function(double progress)? onProgress,
  }) async {
    final data = FormData.fromMap({
      'files': [
        await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
      ],
      'title': title,
    });
    final response = await _api.postMultipart(
      ApiConstants.myLibraryDocuments,
      data: data,
      onSendProgress: onProgress == null
          ? null
          : (sent, total) {
              if (total > 0) onProgress(sent / total);
            },
    );
    final body = response.data;
    final json = body is Map<String, dynamic> ? body['data'] : null;
    if (json is Map<String, dynamic>) {
      return PersonalDocumentModel.fromJson(json);
    }
    throw 'Upload failed';
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _api.delete('${ApiConstants.myLibraryDocuments}/$id');
  }

  @override
  Future<File> downloadDocument({
    required String id,
    required String fileName,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory('${docs.path}/documents');
    if (!await folder.exists()) await folder.create(recursive: true);
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9_.\-]'), '_');
    final file = File('${folder.path}/$safeName');

    try {
      await _api.dio.download(
        ApiConstants.myLibraryDocumentDownload(id),
        file.path,
      );
    } on DioException catch (e) {
      if (await file.exists()) await file.delete();
      throw e.message ?? e.toString();
    }
    return file;
  }
}
