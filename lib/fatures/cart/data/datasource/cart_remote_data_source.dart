// ============================================
// FILE: lib/fatures/cart/data/datasource/cart_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/cart_model.dart';
import '../models/cart_payment_method.dart';
import '../models/checkout_order_model.dart';
import '../../utils/cart_events.dart';

abstract class CartRemoteDataSource {
  /// GET /reader/cart
  Future<CartModel> getCart();

  /// POST /reader/cart/items
  /// body: { "type": "book|package|article|issue", "id": "...", "is_gift": bool }
  Future<void> addItem({
    required String type,
    required String id,
    bool isGift = false,
  });

  /// PATCH /reader/cart/items/{cartItemId}/gift  body: { "is_gift": bool }
  Future<void> setItemGift(String cartItemId, bool isGift);

  /// Sets every item in [cart] (fetched when omitted) to [isGift], patching
  /// only the items that differ.
  Future<void> setAllItemsGift(bool isGift, {CartModel? cart});

  /// DELETE /reader/cart/items/{cartItemId}
  Future<void> removeItem(String cartItemId);

  /// POST /reader/cart/apply-coupon
  /// body: { "code": "..." }
  Future<void> applyCoupon(String code);

  /// POST /reader/cart/remove-coupon
  Future<void> removeCoupon();

  /// POST /reader/cart/checkout
  /// body: { "payment_method": "apple_pay|google_pay|credit_card|mada|simulated_payment" }
  /// Returns the created order (with its invoice).
  Future<CheckoutOrderModel> checkout(CartPaymentMethod paymentMethod);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiService _api;

  CartRemoteDataSourceImpl(this._api);

  @override
  Future<CartModel> getCart() async {
    final response = await _api.get(ApiConstants.cart);
    final data = response['data'];
    final cart = data is Map<String, dynamic>
        ? CartModel.fromJson(data)
        : CartModel.empty;
    CartEvents.publish(cart);
    return cart;
  }

  @override
  Future<void> addItem({
    required String type,
    required String id,
    bool isGift = false,
  }) async {
    final response = await _api.post(
      ApiConstants.cartItems,
      data: {'type': type, 'id': id, 'is_gift': isGift},
    );
    // Only reached on success — ApiService throws on errors.

    // The cart is all-gift or all-normal: a gift add turns every item into
    // a gift, a normal add turns every item back. The response already
    // carries the whole cart, so only mismatched items are patched.
    try {
      final data = response['data'];
      await setAllItemsGift(
        isGift,
        cart: data is Map<String, dynamic> ? CartModel.fromJson(data) : null,
      );
    } catch (_) {
      // The item itself was added; ApiService already showed the error.
    }
    CartEvents.notifyItemAdded();
    CartEvents.notifyChanged();
  }

  @override
  Future<void> setItemGift(String cartItemId, bool isGift) async {
    await _api.patch(
      '${ApiConstants.cartItems}/$cartItemId/gift',
      data: {'is_gift': isGift},
    );
  }

  @override
  Future<void> setAllItemsGift(bool isGift, {CartModel? cart}) async {
    final current = cart ?? await getCart();
    final mismatched = current.items.where((i) => i.isGift != isGift);
    await Future.wait([for (final i in mismatched) setItemGift(i.id, isGift)]);
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    await _api.delete('${ApiConstants.cartItems}/$cartItemId');
    CartEvents.notifyChanged();
  }

  @override
  Future<void> applyCoupon(String code) async {
    await _api.post(ApiConstants.cartApplyCoupon, data: {'code': code});
  }

  @override
  Future<void> removeCoupon() async {
    await _api.post(ApiConstants.cartRemoveCoupon);
  }

  @override
  Future<CheckoutOrderModel> checkout(CartPaymentMethod paymentMethod) async {
    final response = await _api.post(
      ApiConstants.cartCheckout,
      data: {'payment_method': paymentMethod.apiValue},
    );
    final data = response['data'];
    CartEvents.notifyChanged();
    if (data is Map<String, dynamic>) {
      return CheckoutOrderModel.fromJson(data);
    }
    // A 200 without an order body still means the order went through.
    return const CheckoutOrderModel(
      id: '',
      orderNumber: '',
      summary: CartSummaryModel.empty,
    );
  }
}
