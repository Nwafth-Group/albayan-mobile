// ============================================
// FILE: lib/fatures/cart/screens/confirm_order_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../data/datasource/cart_remote_data_source.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/cart_model.dart';
import '../data/models/cart_payment_method.dart';
import 'payment_success_screen.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/order_summary_card.dart';

class ConfirmOrderScreen extends StatefulWidget {
  final List<CartItemModel> items;
  final CartSummaryModel summary;

  /// Called right after a successful checkout, before navigating to
  /// [PaymentSuccessScreen] — lets the caller (the Cart tab) refresh its own
  /// cubit, since this screen is pushed as a separate route and has no
  /// access to it.
  final VoidCallback? onCheckoutComplete;

  const ConfirmOrderScreen({
    super.key,
    required this.items,
    required this.summary,
    this.onCheckoutComplete,
  });

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  final CartRemoteDataSource _cartDataSource = CartRemoteDataSourceImpl(
    ApiService(),
  );

  bool _isCheckingOut = false;

  Future<void> _checkout() async {
    if (_isCheckingOut) return;
    setState(() => _isCheckingOut = true);
    try {
      // No payment-method picker exists yet, so this defaults to the
      // simulated method — matching the simulated success below until a
      // real payment method selection UI and gateway are wired up.
      final order = await _cartDataSource.checkout(
        CartPaymentMethod.simulatedPayment,
      );
      // The order exists either way, so let the Cart tab re-sync with the
      // server (it clears optimistically and reconciles in the background).
      widget.onCheckoutComplete?.call();
      if (!mounted) return;

      if (!order.isPaid) {
        // e.g. `payment_status: "Pending"` / "Failed" — don't claim success.
        Helpers.showError(AppStrings.paymentNotCompleted.tr());
        AppNavigator.pop();
        return;
      }

      // Replace rather than push: once payment succeeds, going "back" from
      // the success screen should not be able to land the user back on this
      // confirm-and-pay screen and let them submit the same order twice.
      AppNavigator.pushReplacement(PaymentSuccessScreen(order: order));
    } catch (_) {
      // ApiService already surfaced the error via a snackbar.
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return PopScope(
      // Block back navigation (gesture/hardware/AppBar) while the checkout
      // request is in flight, so it can't be abandoned mid-request.
      canPop: !_isCheckingOut,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
                child: Text(
                  AppStrings.confirmYourOrder.tr(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeXLarge,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingMedium,
                    0,
                    AppDimensions.paddingMedium,
                    AppDimensions.paddingLarge,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.items.tr(),
                            style: const TextStyle(
                              fontSize: AppDimensions.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          for (final item in items) ...[
                            _ItemRow(
                              item: item,
                              currency: widget.summary.currency,
                            ),
                            if (item != items.last)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppDimensions.paddingSmall,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: AppColors.surfaceVariant,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    OrderSummaryCard(summary: widget.summary),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.back.tr(),
                        isOutlined: true,
                        textColor: AppColors.primary,
                        onPressed: _isCheckingOut
                            ? null
                            : () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: AppStrings.proceedToPayment.tr(),
                        isLoading: _isCheckingOut,
                        onPressed: _checkout,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItemModel item;
  final String? currency;
  const _ItemRow({required this.item, this.currency});

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.surfaceVariant,
      child: Icon(cartTypeIcon(item.type), color: AppColors.textLight),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: SizedBox(
            width: 76,
            height: 90,
            child: (item.image != null && item.image!.isNotEmpty)
                ? Image.network(
                    item.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => placeholder,
                  )
                : placeholder,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.subLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (item.isGift) const CartGiftBadge(),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              if (item.hasAuthor) ...[
                const SizedBox(height: 3),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              CartItemPrice(item: item, currency: currency),
            ],
          ),
        ),
      ],
    );
  }
}
