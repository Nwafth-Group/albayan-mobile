
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
  bool _addingGift = false;

  /// Spinner state for the "Add to Cart" button.
  bool get isAddingToCart => _addingToCart;

  /// Spinner state for the "Gift" button.
  bool get isAddingGift => _addingGift;

  void _setBusy(bool isGift, bool value) =>
      isGift ? _addingGift = value : _addingToCart = value;

  /// Gift button: the same `POST /reader/cart/items` with `is_gift: true`.
  Future<void> addGiftToCart({
    required CartItemType type,
    required String id,
  }) => addToCart(type: type, id: id, isGift: true);

  Future<void> addToCart({
    required CartItemType type,
    required String id,
    bool isGift = false,
  }) async {
    if (_addingToCart || _addingGift) return;
    setState(() => _setBusy(isGift, true));
    try {
      await _cartDataSource.addItem(
        type: type.apiValue,
        id: id,
        isGift: isGift,
      );
      AppNavigator.showSuccessSnackBar(
        (isGift ? AppStrings.giftAddedToCart : AppStrings.addedToCart).tr(),
      );
    } catch (_) {
      // ApiService already surfaced the error via a snackbar.
    } finally {
      if (mounted) setState(() => _setBusy(isGift, false));
    }
  }
}
