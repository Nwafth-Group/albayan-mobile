// ============================================
// FILE: lib/fatures/settings/data/models/order_model.dart
// ============================================
//
// View models for My Order / Order Details / Invoice, built from
// `GET /reader/orders` items. Each order has the same shape as the
// checkout response, so it's parsed with [CheckoutOrderModel] and then
// flattened here — localized fields (`title`, `seller_name`) resolved to
// the app's current language.

import 'package:easy_localization/easy_localization.dart';

import '../../../../utils/constants.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/data/models/checkout_order_model.dart';

enum OrderStatus { completed, processing, cancelled }

class OrderItemModel {
  final String id;

  /// The purchased content's id (`item_id`), e.g. to reopen the book.
  final String itemId;
  final CartItemType type;
  final bool isGift;

  /// Item type label ("Book", "Issue", ...).
  final String subLabel;
  final String title;

  /// Not returned by the orders API — kept for the item row layout.
  final String author;
  final String? image;
  final double rate;

  /// `unit_price` (before discounts).
  final num oldPrice;

  /// `final_price` (what was paid).
  final num price;

  const OrderItemModel({
    required this.id,
    this.itemId = '',
    this.type = CartItemType.book,
    this.isGift = false,
    required this.subLabel,
    required this.title,
    this.author = '',
    this.image,
    this.rate = 0,
    required this.oldPrice,
    required this.price,
  });

  bool get hasDiscount => oldPrice > price;
}

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final OrderStatus status;

  /// Raw `payment_status` ("Paid", ...).
  final String paymentStatus;
  final List<OrderItemModel> items;
  final num subtotal;
  final num offerDiscount;
  final num couponDiscount;
  final num taxRate;
  final num taxAmount;
  final num totalAmount;
  final String? currency;
  final bool isGift;
  final String? giftCode;

  // Invoice fields.
  final String invoiceNumber;
  final String? qrCode;
  final String sellerName;
  final String sellerAddress;
  final String? sellerMobile;
  final String sellerTaxNumber;
  final String customerName;
  final String? customerEmail;
  final String? customerAddress;
  final String? customerMobile;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    this.paymentStatus = '',
    required this.items,
    required this.subtotal,
    this.offerDiscount = 0,
    required this.couponDiscount,
    this.taxRate = 0,
    required this.taxAmount,
    required this.totalAmount,
    this.currency,
    this.isGift = false,
    this.giftCode,
    required this.invoiceNumber,
    this.qrCode,
    required this.sellerName,
    required this.sellerAddress,
    this.sellerMobile,
    required this.sellerTaxNumber,
    required this.customerName,
    this.customerEmail,
    this.customerAddress,
    this.customerMobile,
  });

  /// Total discount (offer + coupon) — the invoice's DISCOUNT line.
  num get discount => offerDiscount + couponDiscount;

  /// `payment_status` → tab/badge status.
  static OrderStatus statusOf(String? paymentStatus) {
    switch (paymentStatus?.toLowerCase()) {
      case 'paid':
      case 'completed':
        return OrderStatus.completed;
      case 'failed':
      case 'cancelled':
      case 'canceled':
      case 'refunded':
      case 'expired':
        return OrderStatus.cancelled;
      default: // pending / processing / unknown
        return OrderStatus.processing;
    }
  }

  static String typeLabel(CartItemType type) {
    switch (type) {
      case CartItemType.book:
        return AppStrings.cartTypeBook.tr();
      case CartItemType.article:
        return AppStrings.cartTypeArticle.tr();
      case CartItemType.issue:
        return AppStrings.cartTypeIssue.tr();
      case CartItemType.package:
        return AppStrings.cartTypePackage.tr();
    }
  }

  factory OrderModel.fromJson(
    Map<String, dynamic> json, {
    required String languageCode,
  }) => OrderModel.fromCheckout(
    CheckoutOrderModel.fromJson(json),
    languageCode: languageCode,
  );

  /// From an already-parsed order — e.g. the one `POST /reader/cart/checkout`
  /// just returned (payment success → View Order).
  factory OrderModel.fromCheckout(
    CheckoutOrderModel o, {
    required String languageCode,
  }) {
    final invoice = o.invoice;

    return OrderModel(
      id: o.id,
      orderNumber: o.orderNumber,
      createdAt: (o.createdAt ?? o.paidAt ?? DateTime.now()).toLocal(),
      status: statusOf(o.paymentStatus),
      paymentStatus: o.paymentStatus ?? '',
      items: [
        for (final i in o.items)
          OrderItemModel(
            id: i.id,
            itemId: i.itemId,
            type: i.type,
            isGift: i.isGift,
            subLabel: typeLabel(i.type),
            title: i.titleFor(languageCode),
            oldPrice: i.unitPrice,
            price: i.finalPrice,
          ),
      ],
      subtotal: o.summary.subtotal,
      offerDiscount: o.summary.offerDiscount,
      couponDiscount: o.summary.couponDiscount,
      taxRate: o.summary.taxRate,
      taxAmount: o.summary.taxAmount,
      totalAmount: o.summary.totalAmount,
      currency: o.summary.currency,
      isGift: o.isGift,
      giftCode: o.giftCode,
      invoiceNumber: invoice?.invoiceNumber ?? '',
      qrCode: invoice?.qrCode,
      sellerName: invoice?.sellerNameFor(languageCode) ?? '',
      sellerAddress: invoice?.sellerAddress ?? '',
      sellerTaxNumber: invoice?.sellerTaxNumber ?? '',
      customerName: invoice?.customerName ?? '',
      customerEmail: invoice?.customerEmail,
      customerMobile: invoice?.customerMobile,
    );
  }
}
