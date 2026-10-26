// ============================================
// FILE: lib/fatures/library/screens/cubit/library_documents_state.dart
// ============================================

part of 'library_documents_cubit.dart';

enum LibraryDocumentsStatus { initial, loading, success, empty, failure }

class LibraryDocumentsState extends Equatable {
  final LibraryDocumentsStatus status;
  final List<PersonalDocumentModel> documents;
  final String? error;

  /// Uploading a new file (shows the FAB's spinner / disables it).
  final bool isUploading;

  /// Ids currently being deleted (so just that card can show a spinner).
  final Set<String> deletingIds;

  const LibraryDocumentsState({
    this.status = LibraryDocumentsStatus.initial,
    this.documents = const [],
    this.error,
    this.isUploading = false,
    this.deletingIds = const {},
  });

  LibraryDocumentsState copyWith({
    LibraryDocumentsStatus? status,
    List<PersonalDocumentModel>? documents,
    String? error,
    bool? isUploading,
    Set<String>? deletingIds,
  }) {
    return LibraryDocumentsState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      error: error,
      isUploading: isUploading ?? this.isUploading,
      deletingIds: deletingIds ?? this.deletingIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        documents,
        error,
        isUploading,
        deletingIds,
      ];
}
