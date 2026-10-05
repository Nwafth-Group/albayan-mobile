// ============================================
// FILE: lib/fatures/settings/data/models/order_model.dart
// ============================================
//
// View models for My Order / Order Details / Invoice.
//
// TODO(api): there is no orders endpoint yet — [OrderModel.samples] feeds
// the screens until one exists. The checkout response
// (`CheckoutOrderModel`) already has the same shape, so the list/details
// endpoints will most likely map onto these fields 1:1.

enum OrderStatus { completed, processing, cancelled }

class OrderItemModel {
  final String id;
  final String subLabel;
  final String title;
  final String author;
  final String? image;
  final double rate;
  final num oldPrice;
  final num price;

  const OrderItemModel({
    required this.id,
    required this.subLabel,
    required this.title,
    required this.author,
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
  final List<OrderItemModel> items;
  final num subtotal;
  final num taxAmount;
  final num couponDiscount;
  final num totalAmount;

  // Invoice fields.
  final String invoiceNumber;
  final String? qrCode;
  final String sellerName;
  final String sellerAddress;
  final String sellerMobile;
  final String sellerTaxNumber;
  final String customerName;
  final String? customerAddress;
  final String? customerMobile;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.couponDiscount,
    required this.totalAmount,
    required this.invoiceNumber,
    this.qrCode,
    required this.sellerName,
    required this.sellerAddress,
    required this.sellerMobile,
    required this.sellerTaxNumber,
    required this.customerName,
    this.customerAddress,
    this.customerMobile,
  });

  num get discount => couponDiscount;

  static final List<OrderModel> samples = [
    _sample('1', '1232145654', OrderStatus.completed),
    _sample('2', '1232145655', OrderStatus.cancelled),
    _sample('3', '1232145656', OrderStatus.processing),
  ];

  static OrderModel _sample(String id, String number, OrderStatus status) {
    const item = OrderItemModel(
      id: 'item',
      subLabel: 'Lorem lorem , 0908',
      title: r'Adobe abandons $20 billion acquisition of Figma',
      author: 'Dr. Ahmad Hassan',
      rate: 4,
      oldPrice: 340,
      price: 300,
    );
    return OrderModel(
      id: id,
      orderNumber: number,
      createdAt: DateTime(2026, 5, 12, 10, 9),
      status: status,
      items: const [item, item, item],
      subtotal: 35.09,
      taxAmount: 0,
      couponDiscount: 12.09,
      totalAmount: 35.09,
      invoiceNumber: 'INV-20260512-$number',
      sellerName: 'AlByan Publishing Company',
      sellerAddress: 'Riyadh, Saudi Arabia',
      sellerMobile: '+962 799 890 91',
      sellerTaxNumber: '300000000000003',
      customerName: 'Saeed Ali',
      customerAddress: 'Riyadh',
      customerMobile: '+962 799 890 91',
    );
  }
}
