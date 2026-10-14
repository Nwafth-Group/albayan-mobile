// ============================================
// FILE: lib/fatures/settings/screens/orders_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/settings_remote_data_source.dart';
import '../data/models/order_model.dart';
import 'cubit/orders_cubit.dart';
import 'order_details_screen.dart';
import 'widgets/settings_widgets.dart';

/// My Order — `GET /reader/orders`, paginated.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit(
        SettingsRemoteDataSourceImpl(ApiService()),
        languageCode: context.locale.languageCode,
      )..load(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  final _scrollController = ScrollController();

  /// null = All. The tabs filter the loaded orders by `payment_status`.
  OrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<OrdersCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) => _buildBody(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state) {
    final cubit = context.read<OrdersCubit>();

    switch (state.status) {
      case OrdersStatus.initial:
      case OrdersStatus.loading:
        return const LoadingIndicator();

      case OrdersStatus.failure:
        return _Refreshable(
          onRefresh: cubit.refresh,
          child: EmptyState(
            icon: Icons.error_outline,
            title: AppStrings.somethingWentWrong.tr(),
            subtitle: state.error ?? AppStrings.pleaseTryAgain.tr(),
            action: CustomButton(
              text: AppStrings.retry.tr(),
              onPressed: cubit.load,
            ),
          ),
        );

      case OrdersStatus.empty:
      case OrdersStatus.success:
      case OrdersStatus.loadingMore:
        final orders = _filter == null
            ? state.orders
            : state.orders.where((o) => o.status == _filter).toList();

        // A filtered tab may be too short to scroll — keep paging in so
        // matching orders on later pages still show up.
        if (orders.length < 8 && state.hasMore && !state.isLoadingMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) cubit.loadMore();
          });
        }

        if (orders.isEmpty && !state.hasMore) {
          return _Refreshable(
            onRefresh: cubit.refresh,
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.noOrders.tr(),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: cubit.refresh,
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: orders.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              if (i == orders.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
              return _OrderCard(order: orders[i]);
            },
          ),
        );
    }
  }
}

class _Refreshable extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _Refreshable({required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
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
