
// ============================================
// FILE: lib/fatures/favorites/screens/cubit/favorites_state.dart
// ============================================

part of 'favorites_cubit.dart';

enum FavoritesStatus { initial, loading, loadingMore, success, empty, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoriteItemModel> items;
  final PaginationMeta? meta;
  final String? error;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.items = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoadingMore => status == FavoritesStatus.loadingMore;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteItemModel>? items,
    PaginationMeta? meta,
    String? error,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, meta, error];
}
