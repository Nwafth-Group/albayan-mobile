
// ============================================
// FILE: lib/fatures/cart/utils/add_to_cart_mixin.dart
// ============================================
//
// Shared "Add to Cart" behavior for any screen with an add-to-cart button
// (book, article, issue, offer and package screens). Wraps
// `POST /reader/cart/items`, guards against double-taps while a request is
// in flight, and surfaces success/error feedback — errors are already shown
// as a snackbar by `ApiService.post`, so this only shows the success one.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../data/datasource/cart_remote_data_source.dart';
import '../data/models/cart_item_model.dart';

mixin AddToCartStateMixin<T extends StatefulWidget> on State<T> {
  final CartRemoteDataSource _cartDataSource =
      CartRemoteDataSourceImpl(ApiService());

  bool _addingToCart = false;
  bool get isAddingToCart => _addingToCart;

  Future<void> addToCart({
    required CartItemType type,
    required String id,
    bool isGift = false,
  }) async {
    if (_addingToCart) return;
    setState(() => _addingToCart = true);
    try {
      await _cartDataSource.addItem(
        type: type.apiValue,
        id: id,
        isGift: isGift,
      );
      AppNavigator.showSuccessSnackBar(AppStrings.addedToCart.tr());
    } catch (_) {
      // ApiService already surfaced the error via a snackbar.
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }
}
