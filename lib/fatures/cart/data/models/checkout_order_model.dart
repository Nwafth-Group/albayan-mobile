// ============================================
// FILE: lib/fatures/cart/data/models/checkout_order_model.dart
// ============================================
//
// Parses `POST /reader/cart/checkout`'s `data` — the created order:
// { "id", "order_number", "subtotal", "offer_discount", "coupon_discount",
//   "tax_rate", "tax_amount", "total_amount", "currency", "payment_method",
//   "payment_status", "payment_reference", "paid_at", "created_at",
//   "is_gift", "gift_code", "coupon", "items": [...], "invoice": {...} }

import 'cart_item_model.dart';
import 'cart_model.dart';

num _parseNum(dynamic v) {
  if (v is num) return v;
  return num.tryParse(v?.toString() ?? '') ?? 0;
}

String? _str(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// Order/invoice text fields come either as a plain string or as a
/// `{ "ar": ..., "en": ... }` map — pick [languageCode], falling back to
/// whichever translation exists.
String localizedText(dynamic value, String languageCode) {
  if (value is Map) {
    return _str(value[languageCode]) ??
        _str(value['en']) ??
        _str(value['ar']) ??
        (value.values.map(_str).whereType<String>().firstOrNull ?? '');
  }
  return _str(value) ?? '';
}

class CheckoutOrderItem {
  final String id;
  final String itemId;
  final CartItemType type;
  final bool isGift;

  /// Raw `title` — a string or a `{ar, en}` map; see [titleFor].
  final dynamic title;

  final num unitPrice;
  final num offerDiscount;
  final num couponDiscount;
  final num taxAmount;
  final num finalPrice;

  const CheckoutOrderItem({
    required this.id,
    required this.itemId,
    required this.type,
    required this.isGift,
    required this.title,
    required this.unitPrice,
    required this.offerDiscount,
    required this.couponDiscount,
    required this.taxAmount,
    required this.finalPrice,
  });

  String titleFor(String languageCode) => localizedText(title, languageCode);

  factory CheckoutOrderItem.fromJson(Map<String, dynamic> json) {
    return CheckoutOrderItem(
      id: json['id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      type: CartItemTypeApiValue.fromApi(json['item_type']?.toString()),
      isGift: json['is_gift'] == true,
      title: json['title'],
      unitPrice: _parseNum(json['unit_price']),
      offerDiscount: _parseNum(json['offer_discount']),
      couponDiscount: _parseNum(json['coupon_discount']),
      taxAmount: _parseNum(json['tax_amount']),
      finalPrice: _parseNum(json['final_price']),
    );
  }
}

class CheckoutInvoice {
  final String id;
  final String invoiceNumber;
  final dynamic sellerName;
  final String? sellerTaxNumber;
  final String? sellerAddress;
  final String? customerName;
  final String? customerEmail;
  final String? customerMobile;
  final num subtotal;
  final num discountAmount;
  final num vatPercentage;
  final num vatAmount;
  final num totalAmount;
  final String? currency;
  final String? paymentMethod;
  final String? paymentReference;

  /// Base64 ZATCA (TLV) e-invoice payload — render it as a QR code as-is.
  final String? qrCode;

  final String? status;
  final DateTime? createdAt;

  const CheckoutInvoice({
    required this.id,
    required this.invoiceNumber,
    this.sellerName,
    this.sellerTaxNumber,
    this.sellerAddress,
    this.customerName,
    this.customerEmail,
    this.customerMobile,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.vatPercentage = 0,
    this.vatAmount = 0,
    this.totalAmount = 0,
    this.currency,
    this.paymentMethod,
    this.paymentReference,
    this.qrCode,
    this.status,
    this.createdAt,
  });

  String sellerNameFor(String languageCode) =>
      localizedText(sellerName, languageCode);

  factory CheckoutInvoice.fromJson(Map<String, dynamic> json) {
    return CheckoutInvoice(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      sellerName: json['seller_name'],
      sellerTaxNumber: _str(json['seller_tax_number']),
      sellerAddress: _str(json['seller_address']),
      customerName: _str(json['customer_name']),
      customerEmail: _str(json['customer_email']),
      customerMobile: _str(json['customer_mobile']),
      subtotal: _parseNum(json['subtotal']),
      discountAmount: _parseNum(json['discount_amount']),
      vatPercentage: _parseNum(json['vat_percentage']),
      vatAmount: _parseNum(json['vat_amount']),
      totalAmount: _parseNum(json['total_amount']),
      currency: _str(json['currency']),
      paymentMethod: _str(json['payment_method']),
      paymentReference: _str(json['payment_reference']),
      qrCode: _str(json['qr_code']),
      status: _str(json['status']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class CheckoutOrderModel {
  final String id;
  final String orderNumber;

  /// Same keys as the cart `summary`, so the same model is reused.
  final CartSummaryModel summary;

  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentReference;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final bool isGift;
  final String? giftCode;
  final String? couponCode;
  final List<CheckoutOrderItem> items;
  final CheckoutInvoice? invoice;

  const CheckoutOrderModel({
    required this.id,
    required this.orderNumber,
    required this.summary,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentReference,
    this.paidAt,
    this.createdAt,
    this.isGift = false,
    this.giftCode,
    this.couponCode,
    this.items = const [],
    this.invoice,
  });

  /// `payment_status` is "Paid" on success. A missing status is treated as
  /// paid (the request itself succeeded); anything else (e.g. "Pending",
  /// "Failed") is not.
  bool get isPaid {
    final status = paymentStatus?.toLowerCase();
    return status == null || status == 'paid';
  }

  factory CheckoutOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawInvoice = json['invoice'];
    final rawCoupon = json['coupon'];

    return CheckoutOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      summary: CartSummaryModel.fromJson(json),
      paymentMethod: _str(json['payment_method']),
      paymentStatus: _str(json['payment_status']),
      paymentReference: _str(json['payment_reference']),
      paidAt: DateTime.tryParse(json['paid_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      isGift: json['is_gift'] == true,
      giftCode: _str(json['gift_code']),
      couponCode: rawCoupon is Map<String, dynamic>
          ? _str(rawCoupon['code'])
          : _str(rawCoupon),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(CheckoutOrderItem.fromJson)
                .toList()
          : const [],
      invoice: rawInvoice is Map<String, dynamic>
          ? CheckoutInvoice.fromJson(rawInvoice)
          : null,
    );
  }
}
