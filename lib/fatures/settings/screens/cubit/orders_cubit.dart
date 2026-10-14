// ============================================
// FILE: lib/fatures/settings/screens/cubit/orders_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/settings_remote_data_source.dart';
import '../../data/models/order_model.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final SettingsRemoteDataSource dataSource;

  /// Language the localized titles / seller name are resolved to.
  final String languageCode;

  OrdersCubit(this.dataSource, {required this.languageCode})
    : super(const OrdersState());

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh: keeps the current list on screen while re-fetching.
  Future<void> refresh() => _fetch(page: 1, reset: true, silent: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    await _fetch(page: (state.meta?.currentPage ?? 1) + 1, reset: false);
  }

  Future<void> _fetch({
    required int page,
    required bool reset,
    bool silent = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!silent) {
      emit(
        state.copyWith(
          status: reset ? OrdersStatus.loading : OrdersStatus.loadingMore,
          error: null,
        ),
      );
    }

    try {
      final result = await dataSource.getOrders(page: page);
      if (isClosed) return;
      final orders = result.items
          .map((j) => OrderModel.fromJson(j, languageCode: languageCode))
          .toList();
      final merged = reset ? orders : [...state.orders, ...orders];
      emit(
        state.copyWith(
          status: merged.isEmpty ? OrdersStatus.empty : OrdersStatus.success,
          orders: merged,
          meta: result.meta,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: state.orders.isEmpty
              ? OrdersStatus.failure
              : OrdersStatus.success,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }
}
