// ============================================
// FILE: lib/fatures/cart/screens/cart_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.cartTitle.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: AppStrings.cartEmptyTitle.tr(),
        subtitle: AppStrings.cartEmptySubtitle.tr(),
      ),
    );
  }
}
