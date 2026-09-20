
// ============================================
// FILE: lib/fatures/library/screens/cubit/library_issues_state.dart
// ============================================

part of 'library_issues_cubit.dart';

enum LibraryIssuesStatus { initial, loading, loadingMore, success, empty, failure }

class LibraryIssuesState extends Equatable {
  final LibraryIssuesStatus status;
  final List<LibraryIssueModel> issues;
  final PaginationMeta? meta;
  final String? error;

  const LibraryIssuesState({
    this.status = LibraryIssuesStatus.initial,
    this.issues = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == LibraryIssuesStatus.loading;
  bool get isLoadingMore => status == LibraryIssuesStatus.loadingMore;

  LibraryIssuesState copyWith({
    LibraryIssuesStatus? status,
    List<LibraryIssueModel>? issues,
    PaginationMeta? meta,
    String? error,
  }) {
    return LibraryIssuesState(
      status: status ?? this.status,
      issues: issues ?? this.issues,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, issues, meta, error];
}
