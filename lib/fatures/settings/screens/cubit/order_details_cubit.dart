// ============================================
// FILE: lib/fatures/settings/screens/cubit/order_details_cubit.dart
// ============================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/settings_remote_data_source.dart';
import '../../data/models/order_model.dart';

/// Starts from the order already loaded by the list, then refreshes it from
/// `GET /reader/orders/{id}`. Failures keep the order on screen (the list
/// copy is complete), so the state is simply the latest [OrderModel].
class OrderDetailsCubit extends Cubit<OrderModel> {
  final SettingsRemoteDataSource dataSource;
  final String languageCode;

  OrderDetailsCubit(
    this.dataSource,
    OrderModel initial, {
    required this.languageCode,
  }) : super(initial);

  Future<void> refresh() async {
    try {
      final json = await dataSource.getOrder(state.id);
      if (json == null || isClosed) return;
      emit(OrderModel.fromJson(json, languageCode: languageCode));
    } catch (_) {
      // ApiService already surfaced the error; keep the current order.
    }
  }
}
