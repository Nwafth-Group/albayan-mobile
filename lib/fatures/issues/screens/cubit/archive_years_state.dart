// ============================================
// FILE: lib/fatures/issues/screens/cubit/archive_years_state.dart
// ============================================

part of 'archive_years_cubit.dart';

enum ArchiveYearsStatus {
  initial,
  loading,
  loadingMore,
  success,
  empty,
  failure,
}

class ArchiveYearsState extends Equatable {
  final ArchiveYearsStatus status;
  final List<ArchiveYearModel> years;
  final PaginationMeta? meta;
  final String? error;

  const ArchiveYearsState({
    this.status = ArchiveYearsStatus.initial,
    this.years = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoadingMore => status == ArchiveYearsStatus.loadingMore;

  ArchiveYearsState copyWith({
    ArchiveYearsStatus? status,
    List<ArchiveYearModel>? years,
    PaginationMeta? meta,
    String? error,
  }) {
    return ArchiveYearsState(
      status: status ?? this.status,
      years: years ?? this.years,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, years, meta, error];
}
