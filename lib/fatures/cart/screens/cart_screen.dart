// ============================================
// FILE: lib/fatures/cart/screens/cart_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../data/cart_mock_data.dart';
import '../data/models/cart_item_model.dart';
import 'confirm_order_screen.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/order_summary_card.dart';
import 'widgets/promo_code_field.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // TODO: replace with a real cart datasource/cubit once cart/checkout
  // endpoints exist. For now cart state lives only in memory.
  final List<CartItemModel> _items = mockCartItems();
  final _promoController = TextEditingController();

  bool _promoApplied = false;
  String? _promoError;
  num _promoDeduction = 0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  num get _subtotal => _items.fold<num>(0, (s, i) => s + i.newPrice);
  num get _oldSubtotal => _items.fold<num>(0, (s, i) => s + i.oldPrice);
  double get _discountPercent =>
      _oldSubtotal > 0 ? ((_oldSubtotal - _subtotal) / _oldSubtotal * 100) : 0;
  num get _total => (_subtotal - _promoDeduction).clamp(0, double.infinity);

  void _removeItem(CartItemModel item) {
    setState(() => _items.removeWhere((i) => i.id == item.id));
  }

  void _applyPromo() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    // TODO: validate against a real promo-code endpoint. For now "AFFD4"
    // is treated as the only valid demo code.
    setState(() {
      if (code.toUpperCase() == 'AFFD4') {
        _promoApplied = true;
        _promoError = null;
        _promoDeduction = 12.09;
      } else {
        _promoApplied = false;
        _promoDeduction = 0;
        _promoError = AppStrings.invalidPromoCode.tr();
      }
    });
  }

  void _checkout() {
    AppNavigator.push(
      ConfirmOrderScreen(
        items: List.of(_items),
        subtotal: _subtotal,
        discountPercent: _discountPercent,
        promoDeduction: _promoApplied ? _promoDeduction : null,
        total: _total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _items.isEmpty
          ? EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: AppStrings.cartEmptyTitle.tr(),
        subtitle: AppStrings.cartEmptySubtitle.tr(),
      )
          : SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingSmall,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                ),
                children: [
                  for (final item in _items)
                    CartItemCard(
                      item: item,
                      onRemove: () => _removeItem(item),
                    ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  PromoCodeField(
                    controller: _promoController,
                    applied: _promoApplied,
                    errorText: _promoError,
                    onApply: _applyPromo,
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  OrderSummaryCard(
                    subtotal: _subtotal,
                    taxes: 0,
                    discountPercent: _discountPercent,
                    promoDeduction: _promoApplied ? _promoDeduction : null,
                    total: _total,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: CustomButton(
                      text: AppStrings.checkOut.tr(),
                      onPressed: _checkout,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}