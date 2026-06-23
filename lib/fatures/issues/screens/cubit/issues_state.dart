
// ============================================
// FILE: lib/fatures/issues/screens/cubit/issues_state.dart
// ============================================

part of 'issues_cubit.dart';

enum IssuesStatus { initial, loading, loadingMore, success, empty, failure }

class IssuesState extends Equatable {
  final IssuesStatus status;
  final List<IssueModel> issues;
  final PaginationMeta? meta;
  final IssuesFilter filter;
  final String? error;

  const IssuesState({
    this.status = IssuesStatus.initial,
    this.issues = const [],
    this.meta,
    this.filter = const IssuesFilter(),
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == IssuesStatus.loading;
  bool get isLoadingMore => status == IssuesStatus.loadingMore;

  IssuesState copyWith({
    IssuesStatus? status,
    List<IssueModel>? issues,
    PaginationMeta? meta,
    IssuesFilter? filter,
    String? error,
  }) {
    return IssuesState(
      status: status ?? this.status,
      issues: issues ?? this.issues,
      meta: meta ?? this.meta,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, issues, meta, filter, error];
}