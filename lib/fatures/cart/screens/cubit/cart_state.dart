
// ============================================
// FILE: lib/fatures/cart/screens/cubit/cart_state.dart
// ============================================

part of 'cart_cubit.dart';

enum CartStatus { initial, loading, success, empty, failure }

class CartState extends Equatable {
  final CartStatus status;
  final CartModel cart;
  final String? error;

  const CartState({
    this.status = CartStatus.initial,
    this.cart = CartModel.empty,
    this.error,
  });

  bool get isLoading => status == CartStatus.loading;

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    String? error,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, cart, error];
}
