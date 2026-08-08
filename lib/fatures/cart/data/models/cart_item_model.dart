
// ============================================
// FILE: lib/fatures/cart/data/models/cart_item_model.dart
// ============================================

enum CartItemType { book, article, issue, package }

class CartItemModel {
  final String id;
  final CartItemType type;
  final String subLabel;
  final String title;
  final String? image;
  final String author;
  final double rate;
  final num oldPrice;
  final num newPrice;

  const CartItemModel({
    required this.id,
    required this.type,
    required this.subLabel,
    required this.title,
    required this.image,
    required this.author,
    required this.rate,
    required this.oldPrice,
    required this.newPrice,
  });

  bool get hasDiscount => oldPrice > newPrice;
}
