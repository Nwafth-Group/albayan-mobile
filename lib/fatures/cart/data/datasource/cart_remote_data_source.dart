
// ============================================
// FILE: lib/fatures/cart/data/datasource/cart_remote_data_source.dart
// ============================================

import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';

import '../models/cart_model.dart';

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

  /// DELETE /reader/cart/items/{cartItemId}
  Future<void> removeItem(String cartItemId);

  /// POST /reader/cart/apply-coupon
  /// body: { "code": "..." }
  Future<void> applyCoupon(String code);

  /// POST /reader/cart/remove-coupon
  Future<void> removeCoupon();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiService _api;

  CartRemoteDataSourceImpl(this._api);

  @override
  Future<CartModel> getCart() async {
    final response = await _api.get(ApiConstants.cart);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return CartModel.fromJson(data);
    }
    return CartModel.empty;
  }

  @override
  Future<void> addItem({
    required String type,
    required String id,
    bool isGift = false,
  }) async {
    await _api.post(
      ApiConstants.cartItems,
      data: {
        'type': type,
        'id': id,
        'is_gift': isGift,
      },
    );
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    await _api.delete('${ApiConstants.cartItems}/$cartItemId');
  }

  @override
  Future<void> applyCoupon(String code) async {
    await _api.post(ApiConstants.cartApplyCoupon, data: {'code': code});
  }

  @override
  Future<void> removeCoupon() async {
    await _api.post(ApiConstants.cartRemoveCoupon);
  }
}
