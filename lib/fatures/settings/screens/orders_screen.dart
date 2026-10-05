// ============================================
// FILE: lib/fatures/settings/screens/orders_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state.dart';
import '../data/models/order_model.dart';
import 'order_details_screen.dart';
import 'widgets/settings_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// null = All.
  OrderStatus? _filter;

  // TODO(api): load from the orders endpoint once it exists.
  final List<OrderModel> _orders = OrderModel.samples;

  @override
  Widget build(BuildContext context) {
    final orders = _filter == null
        ? _orders
        : _orders.where((o) => o.status == _filter).toList();

    final tabs = <(String, OrderStatus?)>[
      (AppStrings.tabAll.tr(), null),
      (AppStrings.statusCompleted.tr(), OrderStatus.completed),
      (AppStrings.statusProcessing.tr(), OrderStatus.processing),
      (AppStrings.statusCancelled.tr(), OrderStatus.cancelled),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: AppStrings.myOrder.tr()),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: settingsCard(radius: 10),
            child: Row(
              children: [
                for (final (label, status) in tabs)
                  Expanded(
                    child: _Tab(
                      label: label,
                      selected: _filter == status,
                      onTap: () => setState(() => _filter = status),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: AppStrings.noOrders.tr(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (order.status) {
      OrderStatus.completed => (
        HugeIcons.strokeRoundedCheckmarkBadge01,
        const Color(0xFF3FA564),
      ),
      OrderStatus.cancelled => (
        HugeIcons.strokeRoundedCancelCircle,
        AppColors.primary,
      ),
      OrderStatus.processing => (
        HugeIcons.strokeRoundedTimeQuarterPass,
        const Color(0xFF3BB8B0),
      ),
    };

    return GestureDetector(
      onTap: () => AppNavigator.push(OrderDetailsScreen(order: order)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: settingsCard(),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: settingsCard(radius: 10),
              child: Center(
                child: HugeIcon(icon: icon, color: color, size: 26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.orderHash.tr(
                            namedArgs: {'number': order.orderNumber},
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy, hh:mm a').format(order.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.itemsCount.tr(
                            namedArgs: {'count': '${order.items.length}'},
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      MoneyText(amount: order.totalAmount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "35.09 SAR" with the currency in maroon.
class MoneyText extends StatelessWidget {
  final num amount;
  final double fontSize;
  final Color amountColor;

  const MoneyText({
    super.key,
    required this.amount,
    this.fontSize = 10,
    this.amountColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${amount.toStringAsFixed(2)} ',
            style: TextStyle(color: amountColor),
          ),
          TextSpan(
            text: AppStrings.currencySar.tr(),
            style: const TextStyle(color: AppColors.primary),
          ),
        ],
      ),
      style: TextStyle(fontSize: fontSize),
    );
  }
}
