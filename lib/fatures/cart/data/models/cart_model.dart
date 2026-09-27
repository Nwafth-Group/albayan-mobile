
// ============================================
// FILE: lib/fatures/cart/data/models/cart_model.dart
// ============================================
//
// Parses `GET /reader/cart`'s `data`:
// { "cart_id", "items_count", "items": [...], "coupon",
//   "summary": { "subtotal", "offer_discount", "coupon_discount",
//                "tax_rate", "tax_amount", "total_amount", "currency" } }

import 'cart_item_model.dart';

num _parseNum(dynamic v) {
  if (v is num) return v;
  return num.tryParse(v?.toString() ?? '') ?? 0;
}

class CartSummaryModel {
  final num subtotal;
  final num offerDiscount;
  final num couponDiscount;
  final num taxRate;
  final num taxAmount;
  final num totalAmount;
  final String? currency;

  const CartSummaryModel({
    this.subtotal = 0,
    this.offerDiscount = 0,
    this.couponDiscount = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.currency,
  });

  static const empty = CartSummaryModel();

  /// The combined "Discount" line the existing cart UI shows as a
  /// percentage — offer + coupon discount relative to the subtotal.
  double get discountPercent {
    if (subtotal <= 0) return 0;
    return ((offerDiscount + couponDiscount) / subtotal * 100)
        .clamp(0, 100)
        .toDouble();
  }

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      subtotal: _parseNum(json['subtotal']),
      offerDiscount: _parseNum(json['offer_discount']),
      couponDiscount: _parseNum(json['coupon_discount']),
      taxRate: _parseNum(json['tax_rate']),
      taxAmount: _parseNum(json['tax_amount']),
      totalAmount: _parseNum(json['total_amount']),
      currency: json['currency']?.toString(),
    );
  }
}

class CartModel {
  final String cartId;
  final int itemsCount;
  final List<CartItemModel> items;

  /// The applied coupon code, if any — `coupon`'s shape beyond that wasn't
  /// documented, so only the code is read defensively.
  final String? couponCode;

  final CartSummaryModel summary;

  const CartModel({
    this.cartId = '',
    this.itemsCount = 0,
    this.items = const [],
    this.couponCode,
    this.summary = CartSummaryModel.empty,
  });

  static const empty = CartModel();

  bool get isEmpty => items.isEmpty;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(CartItemModel.fromJson)
            .toList()
        : <CartItemModel>[];

    final rawCoupon = json['coupon'];
    final couponCode =
        rawCoupon is Map<String, dynamic> ? rawCoupon['code']?.toString() : null;

    final rawSummary = json['summary'];
    final summary = (rawSummary is Map<String, dynamic>)
        ? CartSummaryModel.fromJson(rawSummary)
        : CartSummaryModel.empty;

    return CartModel(
      cartId: json['cart_id']?.toString() ?? '',
      itemsCount: (json['items_count'] as num?)?.toInt() ?? items.length,
      items: items,
      couponCode: couponCode,
      summary: summary,
    );
  }
}
