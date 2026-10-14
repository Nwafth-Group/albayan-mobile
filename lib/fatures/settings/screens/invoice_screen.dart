// ============================================
// FILE: lib/fatures/settings/screens/invoice_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/settings_remote_data_source.dart';
import '../data/models/order_model.dart';
import 'cubit/invoice_cubit.dart';
import 'invoice_pdf_screen.dart';
import 'widgets/settings_widgets.dart';

/// Shared "View Invoice" screen — opened from anywhere with just an
/// [orderId]; it fetches `GET /reader/orders/{id}/invoice` itself rather
/// than relying on the caller already having a full [OrderModel] loaded.
class InvoiceScreen extends StatelessWidget {
  final String orderId;
  const InvoiceScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InvoiceCubit(
        SettingsRemoteDataSourceImpl(ApiService()),
        orderId: orderId,
        languageCode: context.locale.languageCode,
      )..load(),
      child: const _InvoiceView(),
    );
  }
}

class _InvoiceView extends StatelessWidget {
  const _InvoiceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(
        title: '',
        actions: [
          BlocBuilder<InvoiceCubit, InvoiceState>(
            builder: (context, state) {
              final order = state.order;
              if (order == null) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => AppNavigator.push(
                  InvoicePdfScreen(
                    orderId: order.id,
                    invoiceNumber: order.invoiceNumber,
                  ),
                ),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload04,
                  color: AppColors.primary,
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<InvoiceCubit, InvoiceState>(
          builder: (context, state) {
            switch (state.status) {
              case InvoiceStatus.loading:
                return const LoadingIndicator();
              case InvoiceStatus.failure:
                return EmptyStateWidget(
                  icon: Icons.wifi_off_rounded,
                  message: AppStrings.somethingWentWrong.tr(),
                  message2: state.error,
                  actionText: AppStrings.retry.tr(),
                  onAction: () => context.read<InvoiceCubit>().load(),
                );
              case InvoiceStatus.success:
                return _InvoiceBody(order: state.order!);
            }
          },
        ),
      ),
    );
  }
}

class _InvoiceBody extends StatelessWidget {
  final OrderModel order;
  const _InvoiceBody({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: settingsCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(order: order),
            const SizedBox(height: 10),
            const _DotDivider(),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _InfoBox(
                      icon: HugeIcons.strokeRoundedStore01,
                      title: AppStrings.sellerInformation.tr(),
                      lines: [
                        (AppStrings.companyName.tr(), order.sellerName),
                        (AppStrings.addressLabel.tr(), order.sellerAddress),
                        if (order.sellerMobile != null)
                          (AppStrings.mobileNumber.tr(), order.sellerMobile!),
                        (AppStrings.taxNumber.tr(), order.sellerTaxNumber),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoBox(
                      icon: HugeIcons.strokeRoundedUserCircle,
                      title: AppStrings.customerInformation.tr(),
                      lines: [
                        (AppStrings.customerName.tr(), order.customerName),
                        if (order.customerEmail != null)
                          (AppStrings.labelEmail.tr(), order.customerEmail!),
                        if (order.customerAddress != null)
                          (
                            AppStrings.addressLabel.tr(),
                            order.customerAddress!,
                          ),
                        if (order.customerMobile != null)
                          (
                            AppStrings.mobileNumber.tr(),
                            order.customerMobile!,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Strip(order: order),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ItemsTable(items: order.items),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _Totals(order: order),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final OrderModel order;
  const _Header({required this.order});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Image.asset(AppImages.logo, height: 56, fit: BoxFit.contain),
          ),
          const VerticalDivider(color: AppColors.primary, width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.invoiceTitle.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '#${order.invoiceNumber}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                QrImageView(
                  // The ZATCA e-invoice payload when the API provides one.
                  data: order.qrCode ?? order.invoiceNumber,
                  size: 52,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotDivider extends StatelessWidget {
  const _DotDivider();

  @override
  Widget build(BuildContext context) {
    Widget dot() => Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
    );
    Widget line() =>
        Expanded(child: Container(height: 1, color: AppColors.primary));

    return Row(children: [line(), dot(), line(), dot(), line()]);
  }
}

class _InfoBox extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final List<(String, String)> lines;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: AppColors.white, size: 11),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final (label, value) in lines)
            if (value.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, bottom: 2),
                child: Text(
                  '$label: $value',
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Maroon total | date | invoice number strip.
class _Strip extends StatelessWidget {
  final OrderModel order;
  const _Strip({required this.order});

  @override
  Widget build(BuildContext context) {
    const light = TextStyle(fontSize: 7, color: AppColors.primary);

    Widget cell(String text, {bool dark = false}) => Expanded(
      child: Container(
        height: 26,
        alignment: Alignment.center,
        color: dark ? AppColors.primary : AppColors.accentPale,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: dark ? light.copyWith(color: AppColors.white) : light,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          cell(settingsMoney(order.totalAmount), dark: true),
          cell(DateFormat('dd/MM/yyyy, hh:mm a').format(order.createdAt)),
          cell('#${order.invoiceNumber}'),
        ],
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  final List<OrderItemModel> items;
  const _ItemsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    const head = TextStyle(
      fontSize: 7,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    );
    const cell = TextStyle(fontSize: 7, color: AppColors.textPrimary);

    Widget row(List<Widget> cells) => Row(
      children: [
        SizedBox(width: 16, child: cells[0]),
        Expanded(flex: 5, child: cells[1]),
        Expanded(flex: 2, child: cells[2]),
        Expanded(flex: 2, child: cells[3]),
      ],
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accentPale,
            borderRadius: BorderRadius.circular(6),
          ),
          child: row([
            const Text('#', style: head),
            Text(AppStrings.itemsImageName.tr(), style: head),
            Text(AppStrings.priceLabel.tr(), style: head),
            Text(
              AppStrings.totalLabel.tr(),
              style: head,
              textAlign: TextAlign.end,
            ),
          ]),
        ),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: row([
              Text('${i + 1}', style: cell),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      width: 18,
                      height: 22,
                      color: AppColors.surfaceVariant,
                      child: items[i].image == null
                          ? null
                          : Image.network(
                              items[i].image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      items[i].title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: cell,
                    ),
                  ),
                ],
              ),
              // Unit price, then the line total after discounts.
              Text(items[i].oldPrice.toStringAsFixed(2), style: cell),
              Text(
                settingsMoney(items[i].price),
                style: cell,
                textAlign: TextAlign.end,
              ),
            ]),
          ),
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  final OrderModel order;
  const _Totals({required this.order});

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(fontSize: 7, color: AppColors.primary);
    const value = TextStyle(fontSize: 7, color: AppColors.textPrimary);

    Widget line(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(l, style: label)),
          Text(v, style: value),
        ],
      ),
    );

    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          line(
            AppStrings.subtotal.tr().toUpperCase(),
            settingsMoney(order.subtotal),
          ),
          line(
            AppStrings.discount.tr().toUpperCase(),
            settingsMoney(order.discount),
          ),
          const Divider(height: 14, color: settingsBorder),
          Text(AppStrings.totalLabel.tr().toUpperCase(), style: label),
          const SizedBox(height: 2),
          Text(
            settingsMoney(order.totalAmount),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
