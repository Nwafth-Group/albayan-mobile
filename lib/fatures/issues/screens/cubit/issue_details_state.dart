
// ============================================
// FILE: lib/fatures/issues/screens/cubit/issue_details_state.dart
// ============================================

part of 'issue_details_cubit.dart';

enum DetailsStatus { initial, loading, success, failure }

class IssueDetailsState extends Equatable {
  final DetailsStatus status;
  final IssueDetailModel? detail;
  final String? error;

  const IssueDetailsState({
    this.status = DetailsStatus.initial,
    this.detail,
    this.error,
  });

  IssueDetailsState copyWith({
    DetailsStatus? status,
    IssueDetailModel? detail,
    String? error,
  }) {
    return IssueDetailsState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, detail, error];
}