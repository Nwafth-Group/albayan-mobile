
// ============================================
// FILE: lib/fatures/corners/screens/cubit/corners_list_state.dart
// ============================================

part of 'corners_list_cubit.dart';

enum CornersListStatus { initial, loading, loadingMore, success, empty, failure }

class CornersListState extends Equatable {
  final CornersListStatus status;
  final List<CornerModel> corners;
  final PaginationMeta? meta;
  final String query;
  final String? error;

  const CornersListState({
    this.status = CornersListStatus.initial,
    this.corners = const [],
    this.meta,
    this.query = '',
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == CornersListStatus.loading;
  bool get isLoadingMore => status == CornersListStatus.loadingMore;

  CornersListState copyWith({
    CornersListStatus? status,
    List<CornerModel>? corners,
    PaginationMeta? meta,
    String? query,
    String? error,
  }) {
    return CornersListState(
      status: status ?? this.status,
      corners: corners ?? this.corners,
      meta: meta ?? this.meta,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, corners, meta, query, error];
}
