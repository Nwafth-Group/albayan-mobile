// ============================================
// FILE: lib/fatures/reader/data/datasource/reader_remote_datasource.dart
// ============================================

import '../../../../utils/api_client.dart';
import '../../../../utils/constants.dart';
import '../models/reader_models.dart';

abstract class ReaderRemoteDataSource {
  /// POST /reader/my-library/books/sync
  /// Pushes each book's current page, highlights and bookmarks so the
  /// backend has the latest reading state.
  Future<void> syncBooks(List<BookSyncItem> books);

  /// POST /reader/my-library/documents/sync — same payload shape, for
  /// personal documents (My Documents) instead of library books.
  Future<void> syncDocuments(List<BookSyncItem> documents);
}

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  final ApiService _api;

  ReaderRemoteDataSourceImpl(this._api);

  @override
  Future<void> syncBooks(List<BookSyncItem> books) async {
    if (books.isEmpty) return;
    await _api.post(
      ApiConstants.myLibraryBooksSync,
      data: {'my_books': books.map((b) => b.toJson()).toList()},
    );
  }

  @override
  Future<void> syncDocuments(List<BookSyncItem> documents) async {
    if (documents.isEmpty) return;
    await _api.post(
      ApiConstants.myLibraryDocumentsSync,
      data: {'my_documents': documents.map((d) => d.toJson()).toList()},
    );
  }
}
