// ============================================
// FILE: lib/fatures/cart/utils/cart_events.dart
// ============================================
//
// App-wide "the cart changed on the server" signal. Every [CartCubit]
// listens and re-fetches `GET /reader/cart`, so the Cart tab (kept alive in
// the bottom-nav IndexedStack) and any pushed cart page stay in sync after
// an item is added from another screen.
//
// Every fetched cart is also broadcast on [carts], so other UI (the
// bottom-nav badge) follows it without fetching the cart again.

import 'dart:async';

import '../data/models/cart_model.dart';

class CartEvents {
  CartEvents._();

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _controller.stream;

  static void notifyChanged() => _controller.add(null);

  static final StreamController<void> _addedController =
      StreamController<void>.broadcast();

  /// Fires after an item is added to the cart (from any screen) — the Cart
  /// screen uses it to reset its promo-code field.
  static Stream<void> get itemAdded => _addedController.stream;

  static void notifyItemAdded() => _addedController.add(null);

  static final StreamController<CartModel> _cartsController =
      StreamController<CartModel>.broadcast();

  static Stream<CartModel> get carts => _cartsController.stream;

  static void publish(CartModel cart) => _cartsController.add(cart);
}
