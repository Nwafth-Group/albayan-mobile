
// ============================================
// FILE: lib/fatures/cart/data/models/cart_item_model.dart
// ============================================
//
// Parses one entry of `GET /reader/cart`'s `data.items`:
// { "id", "item_id", "item_type", "is_gift", "title", "author",
//   "subtitle", "image_url", "original_price", "offer_discount",
//   "final_price", "active_offer" }

enum CartItemType { book, article, issue, package }

/// The `type` value the `POST /reader/cart/items` endpoint expects, and
/// the `item_type` value `GET /reader/cart` returns.
extension CartItemTypeApiValue on CartItemType {
  String get apiValue {
    switch (this) {
      case CartItemType.book:
        return 'book';
      case CartItemType.article:
        return 'article';
      case CartItemType.issue:
        return 'issue';
      case CartItemType.package:
        return 'package';
    }
  }

  static CartItemType fromApi(String? value) {
    switch (value) {
      case 'article':
        return CartItemType.article;
      case 'issue':
        return CartItemType.issue;
      case 'package':
        return CartItemType.package;
      case 'book':
      default:
        return CartItemType.book;
    }
  }
}

class CartItemModel {
  /// The cart row id (`id`) — not the underlying book/article/issue id.
  final String id;

  /// The underlying content id (`item_id`), e.g. to reopen the book/article.
  final String itemId;

  final CartItemType type;
  final bool isGift;
  final String subLabel;
  final String title;
  final String? image;
  final String author;

  /// Not returned by `GET /reader/cart` — kept so the existing cart UI
  /// (which shows a star row) still renders; always 0 until the backend
  /// includes a rating here.
  final double rate;

  final num oldPrice;
  final num newPrice;

  const CartItemModel({
    required this.id,
    required this.itemId,
    required this.type,
    required this.isGift,
    required this.subLabel,
    required this.title,
    required this.image,
    required this.author,
    required this.rate,
    required this.oldPrice,
    required this.newPrice,
  });

  bool get hasDiscount => oldPrice > newPrice;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic v) {
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    }

    final originalPrice = parseNum(json['original_price']);
    final finalPrice = parseNum(json['final_price']);

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      type: CartItemTypeApiValue.fromApi(json['item_type']?.toString()),
      isGift: json['is_gift'] == true,
      subLabel: json['subtitle']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image_url']?.toString(),
      author: json['author']?.toString() ?? '',
      rate: 0,
      oldPrice: originalPrice,
      newPrice: finalPrice,
    );
  }
}
