// ============================================
// FILE: lib/fatures/cart/screens/cart_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/cart_remote_data_source.dart';
import '../data/models/cart_item_model.dart';
import 'confirm_order_screen.dart';
import 'cubit/cart_cubit.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/order_summary_card.dart';
import 'widgets/promo_code_field.dart';

class CartScreen extends StatelessWidget {
  /// True when pushed as its own page (e.g. from a header cart icon) rather
  /// than shown as the bottom-nav Cart tab — adds a back-button app bar.
  final bool showAppBar;

  const CartScreen({Key? key, this.showAppBar = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(CartRemoteDataSourceImpl(ApiService()))..load(),
      child: _CartView(showAppBar: showAppBar),
    );
  }
}

class _CartView extends StatefulWidget {
  final bool showAppBar;

  const _CartView({required this.showAppBar});

  @override
  State<_CartView> createState() => _CartViewState();
}

class _CartViewState extends State<_CartView> {
  final _promoController = TextEditingController();

  bool _promoBusy = false;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _removeItem(BuildContext context, CartItemModel item) {
    context.read<CartCubit>().removeItem(item);
  }

  Future<void> _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty || _promoBusy) return;
    setState(() {
      _promoBusy = true;
      _promoError = null;
    });
    final error = await context.read<CartCubit>().applyCoupon(code);
    if (!mounted) return;
    setState(() {
      _promoBusy = false;
      _promoError = error;
    });
  }

  Future<void> _removePromo() async {
    if (_promoBusy) return;
    setState(() {
      _promoBusy = true;
      _promoError = null;
    });
    final error = await context.read<CartCubit>().removeCoupon();
    if (!mounted) return;
    setState(() {
      _promoBusy = false;
      _promoError = error;
      if (error == null) _promoController.clear();
    });
  }

  void _checkout(BuildContext context, CartState state) {
    final summary = state.cart.summary;
    final cartCubit = context.read<CartCubit>();

    AppNavigator.push(
      ConfirmOrderScreen(
        items: List.of(state.cart.items),
        summary: summary,
        // Captured here (this context has the BlocProvider ancestor) since
        // ConfirmOrderScreen is pushed as a separate route and can't reach
        // this tab's CartCubit on its own.
        onCheckoutComplete: () {
          cartCubit.clearAfterCheckout();
          _promoController.clear();
          if (mounted) setState(() => _promoError = null);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        // As the bottom-nav tab there is nothing to pop, so hide the back arrow.
        showBack: widget.showAppBar,
        centerTitle: true,
        title: AppStrings.myCart.tr(),
        color: AppColors.textPrimary,
        titleFontSize: AppDimensions.fontSizeXLarge,
        titleFontWeight: FontWeight.w500,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          switch (state.status) {
            case CartStatus.initial:
            case CartStatus.loading:
              return const LoadingIndicator();

            case CartStatus.failure:
              return EmptyState(
                icon: Icons.error_outline,
                title: AppStrings.somethingWentWrong.tr(),
                subtitle: state.error ?? AppStrings.pleaseTryAgain.tr(),
                action: CustomButton(
                  text: AppStrings.retry.tr(),
                  onPressed: () => context.read<CartCubit>().load(),
                ),
              );

            case CartStatus.empty:
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<CartCubit>().refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: EmptyState(
                        icon: Icons.shopping_cart_outlined,
                        title: AppStrings.cartEmptyTitle.tr(),
                        subtitle: AppStrings.cartEmptySubtitle.tr(),
                      ),
                    ),
                  ],
                ),
              );

            case CartStatus.success:
              final items = state.cart.items;
              final summary = state.cart.summary;
              final couponCode = state.cart.couponCode;
              final couponApplied = couponCode != null && couponCode.isNotEmpty;

              if (couponApplied && _promoController.text != couponCode) {
                _promoController.text = couponCode;
              }

              return SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => context.read<CartCubit>().refresh(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.paddingMedium,
                            AppDimensions.paddingSmall,
                            AppDimensions.paddingMedium,
                            AppDimensions.paddingLarge,
                          ),
                          children: [
                            for (final item in items)
                              CartItemCard(
                                item: item,
                                currency: summary.currency,
                                onRemove: () => _removeItem(context, item),
                              ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            PromoCodeField(
                              controller: _promoController,
                              applied: couponApplied,
                              isLoading: _promoBusy,
                              errorText: _promoError,
                              onApply: _applyPromo,
                              onRemove: _removePromo,
                            ),
                            const SizedBox(height: AppDimensions.paddingLarge),
                            OrderSummaryCard(summary: summary),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingMedium,
                            ),
                            child: CustomButton(
                              text: AppStrings.checkOut.tr(),
                              onPressed: () => _checkout(context, state),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
