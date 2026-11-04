// ============================================
// FILE: lib/fatures/settings/screens/subscription_history_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/subscription_remote_data_source.dart';
import 'cubit/subscription_history_cubit.dart';
import 'widgets/settings_widgets.dart';
import 'widgets/subscription_widgets.dart';

enum _HistoryFilter { all, active, expired }

/// Subscription History — `GET /reader/subscriptions/history`, paginated,
/// with All / Active / Expired tabs filtering the loaded items.
class SubscriptionHistoryScreen extends StatelessWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubscriptionHistoryCubit(
        SubscriptionRemoteDataSourceImpl(ApiService()),
        languageCode: context.locale.languageCode,
      )..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final _scrollController = ScrollController();
  _HistoryFilter _filter = _HistoryFilter.all;

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
      context.read<SubscriptionHistoryCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <(String, _HistoryFilter)>[
      (AppStrings.tabAll.tr(), _HistoryFilter.all),
      (AppStrings.subActive.tr(), _HistoryFilter.active),
      (AppStrings.subExpired.tr(), _HistoryFilter.expired),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: AppStrings.subscriptionHistory.tr()),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: settingsCard(radius: 10),
            child: Row(
              children: [
                for (final (label, filter) in tabs)
                  Expanded(
                    child: _Tab(
                      label: label,
                      selected: _filter == filter,
                      onTap: () => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child:
                BlocBuilder<SubscriptionHistoryCubit, SubscriptionHistoryState>(
                  builder: (context, state) => _buildBody(context, state),
                ),
          ),
        ],
      ),
      bottomNavigationBar: _filter == _HistoryFilter.expired
          ? SettingsBottomButton(
              text: AppStrings.viewAllSubscriptions.tr(),
              onPressed: () => setState(() => _filter = _HistoryFilter.all),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, SubscriptionHistoryState state) {
    final cubit = context.read<SubscriptionHistoryCubit>();

    switch (state.status) {
      case SubscriptionHistoryStatus.initial:
      case SubscriptionHistoryStatus.loading:
        return const LoadingIndicator();

      case SubscriptionHistoryStatus.failure:
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

      case SubscriptionHistoryStatus.empty:
      case SubscriptionHistoryStatus.success:
      case SubscriptionHistoryStatus.loadingMore:
        final items = switch (_filter) {
          _HistoryFilter.all => state.items,
          _HistoryFilter.active => state.items.where((s) => s.isActive).toList(),
          _HistoryFilter.expired =>
            state.items.where((s) => !s.isActive).toList(),
        };

        // A filtered tab may be too short to scroll — keep paging in so
        // matching items on later pages still show up.
        if (items.length < 4 && state.hasMore && !state.isLoadingMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) cubit.loadMore();
          });
        }

        if (items.isEmpty && !state.hasMore) {
          return _Refreshable(
            onRefresh: cubit.refresh,
            child: EmptyState(
              icon: Icons.workspace_premium_outlined,
              title: switch (_filter) {
                _HistoryFilter.all => AppStrings.noSubscriptionHistory.tr(),
                _HistoryFilter.active => AppStrings.noActiveSubscriptions.tr(),
                _HistoryFilter.expired =>
                  AppStrings.noExpiredSubscriptions.tr(),
              },
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
            itemCount: items.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              if (i == items.length) {
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
              return UserSubscriptionCard(
                subscription: items[i],
                plan: state.planFor(items[i]),
              );
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
