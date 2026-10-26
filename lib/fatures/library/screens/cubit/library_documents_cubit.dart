// ============================================
// FILE: lib/fatures/library/screens/cubit/library_documents_cubit.dart
// ============================================

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/datasource/library_documents_remote_data_source.dart';
import '../../data/models/personal_document_model.dart';

part 'library_documents_state.dart';

class LibraryDocumentsCubit extends Cubit<LibraryDocumentsState> {
  final LibraryDocumentsRemoteDataSource dataSource;

  LibraryDocumentsCubit(this.dataSource) : super(const LibraryDocumentsState());

  Future<void> load() async {
    emit(state.copyWith(status: LibraryDocumentsStatus.loading));
    try {
      final documents = await dataSource.getDocuments();
      emit(
        state.copyWith(
          status: documents.isEmpty
              ? LibraryDocumentsStatus.empty
              : LibraryDocumentsStatus.success,
          documents: documents,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: LibraryDocumentsStatus.failure, error: '$e'),
      );
    }
  }

  Future<bool> upload(File file, String title) async {
    if (state.isUploading) return false;
    emit(state.copyWith(isUploading: true));
    try {
      final document = await dataSource.upload(file: file, title: title);
      emit(
        state.copyWith(
          status: LibraryDocumentsStatus.success,
          documents: [document, ...state.documents],
          isUploading: false,
        ),
      );
      return true;
    } catch (_) {
      // ApiService already surfaced the error via a snackbar.
      emit(state.copyWith(isUploading: false));
      return false;
    }
  }

  /// Downloads the document's file (`GET .../download`) and hands it to the
  /// OS share sheet so the user can save it elsewhere or open it in another
  /// app — there's no in-app "Downloads" folder UI to view it otherwise.
  Future<void> download(PersonalDocumentModel document) async {
    try {
      final fileName = document.file.fileName.isNotEmpty
          ? document.file.fileName
          : '${document.title}.pdf';
      final file = await dataSource.downloadDocument(
        id: document.id,
        fileName: fileName,
      );
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: document.title),
      );
    } catch (_) {
      // ApiService already surfaced the error via a snackbar.
    }
  }

  Future<void> delete(String id) async {
    if (state.deletingIds.contains(id)) return;
    emit(
      state.copyWith(deletingIds: {...state.deletingIds, id}),
    );
    try {
      await dataSource.deleteDocument(id);
      final remaining =
          state.documents.where((d) => d.id != id).toList();
      emit(
        state.copyWith(
          documents: remaining,
          status: remaining.isEmpty
              ? LibraryDocumentsStatus.empty
              : LibraryDocumentsStatus.success,
          deletingIds: {...state.deletingIds}..remove(id),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds}..remove(id),
        ),
      );
    }
  }
}
