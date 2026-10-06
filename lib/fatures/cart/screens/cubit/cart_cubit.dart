// ============================================
// FILE: lib/fatures/cart/screens/cubit/cart_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/helpers.dart';
import '../../data/datasource/cart_remote_data_source.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_model.dart';
import '../../utils/cart_events.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRemoteDataSource dataSource;

  StreamSubscription<void>? _cartChangesSub;

  CartCubit(this.dataSource) : super(const CartState()) {
    // Re-fetch the cart whenever an item is added from any screen.
    _cartChangesSub = CartEvents.changes.listen((_) => _refreshSilently());
  }

  @override
  Future<void> close() {
    _cartChangesSub?.cancel();
    return super.close();
  }

  Future<void> load() => _fetch();

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    emit(state.copyWith(status: CartStatus.loading, error: null));
    try {
      final cart = await dataSource.getCart();
      emit(
        state.copyWith(
          status: cart.isEmpty ? CartStatus.empty : CartStatus.success,
          cart: cart,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, error: e.toString()));
    }
  }

  /// Re-fetches the cart without switching the screen to the full loading
  /// state — used after a mutation (remove item / coupon) so the list stays
  /// on screen while the summary (totals, coupon) refreshes underneath it.
  Future<void> _refreshSilently() async {
    try {
      final cart = await dataSource.getCart();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: cart.isEmpty ? CartStatus.empty : CartStatus.success,
          cart: cart,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: CartStatus.failure, error: e.toString()));
    }
  }

  /// DELETE /reader/cart/items/{id} — removes optimistically, rolls back and
  /// surfaces the error if the request fails.
  Future<void> removeItem(CartItemModel item) async {
    final previous = state.cart;
    final optimistic = previous.items.where((i) => i.id != item.id).toList();
    emit(
      state.copyWith(
        cart: CartModel(
          cartId: previous.cartId,
          itemsCount: optimistic.length,
          items: optimistic,
          couponCode: previous.couponCode,
          summary: previous.summary,
        ),
        status: optimistic.isEmpty ? CartStatus.empty : CartStatus.success,
      ),
    );

    try {
      await dataSource.removeItem(item.id);
      await _refreshSilently();
    } catch (e) {
      Helpers.showError(e.toString());
      emit(
        state.copyWith(
          cart: previous,
          status: previous.items.isEmpty
              ? CartStatus.empty
              : CartStatus.success,
        ),
      );
    }
  }

  /// POST /reader/cart/apply-coupon — returns an error message on failure,
  /// or null on success (the cart, including the applied coupon and the
  /// recalculated summary, is refreshed in place).
  Future<String?> applyCoupon(String code) async {
    try {
      await dataSource.applyCoupon(code);
      await _refreshSilently();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// POST /reader/cart/remove-coupon
  Future<String?> removeCoupon() async {
    try {
      await dataSource.removeCoupon();
      await _refreshSilently();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Called right after `POST /reader/cart/checkout` succeeds. A completed
  /// order should always leave the cart empty, so this clears it immediately
  /// (instead of waiting on a round trip) and then reconciles with the
  /// server in the background in case anything was left behind.
  void clearAfterCheckout() {
    emit(state.copyWith(status: CartStatus.empty, cart: CartModel.empty));
    _refreshSilently();
  }
}
