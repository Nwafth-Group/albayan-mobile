
// ============================================
// FILE: lib/fatures/cart/data/cart_mock_data.dart
// ============================================
//
// NOTE: No cart/checkout endpoints have been provided yet. This seeds the
// cart with a couple of mock items so the UI can be built and reviewed.
// Once real cart/checkout endpoints exist, replace this (and the local
// state in CartScreen) with a real datasource/cubit — the screens only
// depend on `CartItemModel`.

import 'models/cart_item_model.dart';

const _horsesImage =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac440a79_book2.jpg';
const _kaabaImage =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac44aa1e_book3.jpg';

List<CartItemModel> mockCartItems() => [
      const CartItemModel(
        id: 'cart-article-1',
        type: CartItemType.article,
        subLabel: 'Lorem lorem , 0908',
        title: 'Adobe abandons \$20 billion acquisition of Figma',
        image: _horsesImage,
        author: 'Dr. Ahmad Hassan',
        rate: 4.5,
        oldPrice: 35.09,
        newPrice: 35.09,
      ),
      const CartItemModel(
        id: 'cart-issue-1',
        type: CartItemType.issue,
        subLabel: 'Lorem lorem , 0908',
        title: 'Adobe abandons \$20 billion acquisition of Figma',
        image: _kaabaImage,
        author: 'Dr. Ahmad Hassan',
        rate: 4.5,
        oldPrice: 340,
        newPrice: 300,
      ),
    ];
