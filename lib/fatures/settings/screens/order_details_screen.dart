// ============================================
// FILE: lib/fatures/settings/screens/order_details_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../data/models/order_model.dart';
import 'invoice_screen.dart';
import 'widgets/settings_widgets.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: AppStrings.orderDetails.tr()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: settingsCard(),
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy, hh:mm a').format(order.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Items ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: settingsCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.items.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ItemRow(item: item),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Summary ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: settingsCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.orderSummary.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  AppStrings.subtotal.tr(),
                  settingsMoney(order.subtotal),
                ),
                _SummaryRow(
                  AppStrings.taxes.tr(),
                  settingsMoney(order.taxAmount),
                ),
                _SummaryRow(
                  AppStrings.promoCode.tr(),
                  order.couponDiscount > 0
                      ? '-${order.couponDiscount.toStringAsFixed(2)}'
                      : '-',
                  valueColor: AppColors.primary,
                ),
                const Divider(height: 20, color: settingsBorder),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.totalAmount.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      settingsMoney(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SettingsButtonPair(
        secondaryText: AppStrings.downloadInvoice.tr(),
        primaryText: AppStrings.viewInvoice.tr(),
        // TODO(api): download the invoice PDF once an endpoint provides it.
        onSecondary: () => Helpers.showError(AppStrings.featureComingSoon.tr()),
        onPrimary: () => AppNavigator.push(InvoiceScreen(order: order)),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemModel item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.image_outlined, color: AppColors.textLight),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 64,
            height: 72,
            child: (item.image == null || item.image!.isEmpty)
                ? placeholder
                : Image.network(
                    item.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => placeholder,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.subLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              if (item.author.isNotEmpty)
                Text(
                  item.author,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              if (item.rate > 0)
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < item.rate ? Icons.star : Icons.star_border,
                      size: 10,
                      color: Colors.amber,
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (item.hasDiscount) ...[
                    Text(
                      settingsMoney(item.oldPrice),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    settingsMoney(item.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
