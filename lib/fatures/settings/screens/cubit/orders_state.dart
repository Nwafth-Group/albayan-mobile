// ============================================
// FILE: lib/fatures/settings/screens/cubit/orders_state.dart
// ============================================

part of 'orders_cubit.dart';

enum OrdersStatus { initial, loading, loadingMore, success, empty, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderModel> orders;
  final PaginationMeta? meta;
  final String? error;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoadingMore => status == OrdersStatus.loadingMore;

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderModel>? orders,
    PaginationMeta? meta,
    String? error,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, orders, meta, error];
}
