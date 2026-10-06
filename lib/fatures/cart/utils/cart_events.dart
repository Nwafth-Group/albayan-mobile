// ============================================
// FILE: lib/fatures/cart/utils/cart_events.dart
// ============================================
//
// App-wide "the cart changed on the server" signal. Every [CartCubit]
// listens and re-fetches `GET /reader/cart`, so the Cart tab (kept alive in
// the bottom-nav IndexedStack) and any pushed cart page stay in sync after
// an item is added from another screen.

import 'dart:async';

class CartEvents {
  CartEvents._();

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _controller.stream;

  static void notifyChanged() => _controller.add(null);
}
