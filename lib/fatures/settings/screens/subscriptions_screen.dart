// ============================================
// FILE: lib/fatures/settings/screens/subscriptions_screen.dart
// ============================================

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/subscription_remote_data_source.dart';
import '../data/models/subscription_model.dart';
import 'cubit/subscriptions_cubit.dart';
import 'subscription_history_screen.dart';
import 'widgets/settings_widgets.dart';
import 'widgets/subscription_widgets.dart';

/// My Subscriptions — `GET /reader/subscriptions/current`, with the
/// Upgrade Plan sheet (`/public/subscriptions/plans` + `purchase`).
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubscriptionsCubit(
        SubscriptionRemoteDataSourceImpl(ApiService()),
        languageCode: context.locale.languageCode,
      )..load(),
      child: const _SubscriptionsView(),
    );
  }
}

class _SubscriptionsView extends StatelessWidget {
  const _SubscriptionsView();

  /// Store subscriptions are cancelled / changed from the store's own
  /// account page.
  Future<void> _manage() async {
    final Uri? url;
    if (!kIsWeb && Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else if (!kIsWeb && Platform.isAndroid) {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    } else {
      url = null;
    }
    if (url == null ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Helpers.showError(AppStrings.featureComingSoon.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
      builder: (context, state) {
        final cubit = context.read<SubscriptionsCubit>();
        final current = state.current;
        final loaded = state.status == SubscriptionsStatus.success;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: SettingsAppBar(
            title: AppStrings.mySubscriptions.tr(),
            actions: [
              IconButton(
                onPressed: () => showUpgradePlanSheet(context),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedShield01,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () =>
                    AppNavigator.push(const SubscriptionHistoryScreen()),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedWorkHistory,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          body: switch (state.status) {
            SubscriptionsStatus.initial ||
            SubscriptionsStatus.loading => const LoadingIndicator(),
            SubscriptionsStatus.failure => _Refreshable(
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
            ),
            SubscriptionsStatus.success when current == null => _Refreshable(
              onRefresh: cubit.refresh,
              child: EmptyState(
                icon: Icons.workspace_premium_outlined,
                title: AppStrings.noSubscriptionTitle.tr(),
                subtitle: AppStrings.noSubscriptionDesc.tr(),
              ),
            ),
            SubscriptionsStatus.success => RefreshIndicator(
              color: AppColors.primary,
              onRefresh: cubit.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _SubscriptionCard(
                    subscription: current!,
                    plan: state.currentPlan,
                  ),
                ],
              ),
            ),
          },
          bottomNavigationBar: !loaded
              ? null
              : current?.isActive == true &&
                    FeatureFlags.manageSubscriptionEnabled
              ? SettingsButtonPair(
                  secondaryText: AppStrings.subUpgrade.tr(),
                  primaryText: AppStrings.manageSubscription.tr(),
                  onSecondary: () => showUpgradePlanSheet(context),
                  onPrimary: _manage,
                )
              : current?.isActive == true
              // Manage is hidden → Upgrade on its own.
              ? SettingsBottomButton(
                  text: AppStrings.subUpgrade.tr(),
                  onPressed: () => showUpgradePlanSheet(context),
                )
              : SettingsBottomButton(
                  text: AppStrings.subscribeNow.tr(),
                  onPressed: () => showUpgradePlanSheet(context),
                ),
        );
      },
    );
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

class _SubscriptionCard extends StatelessWidget {
  final UserSubscriptionModel subscription;
  final SubscriptionPlanModel? plan;

  const _SubscriptionCard({required this.subscription, this.plan});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy');
    String fmt(DateTime? d) => d == null ? '-' : date.format(d);
    final s = subscription;

    final (statusFg, statusBg) = s.isActive
        ? (const Color(0xFF3FA564), const Color(0xFFDDF3E4))
        : (AppColors.primary, AppColors.accentPale);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: settingsCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan?.name ?? s.planName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscriptionStatusLabel(s.status),
                  style: TextStyle(fontSize: 10, color: statusFg),
                ),
              ),
            ],
          ),
          Text(
            AppStrings.monthsCount.tr(
              namedArgs: {'count': '${s.durationMonths}'},
            ),
            style: const TextStyle(fontSize: 10, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          _InfoRow(AppStrings.startDate.tr(), fmt(s.startDate)),
          _InfoRow(AppStrings.endDate.tr(), fmt(s.endDate)),
          if (s.isAutoRenew && s.renewalDate != null)
            _InfoRow(AppStrings.autoRenewal.tr(), fmt(s.renewalDate)),
          _InfoRow(
            AppStrings.renewsOn.tr(),
            (s.isAutoRenew ? AppStrings.toggleOn : AppStrings.toggleOff).tr(),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, color: settingsBorder),
          const SizedBox(height: 14),
          SubscriptionPlanCard(
            price: s.price ?? plan?.price,
            currency: s.currency ?? plan?.currency,
            title: s.planName,
            period: subscriptionDurationLabel(s.duration, s.durationMonths),
            features: plan != null
                ? planFeatures(plan!)
                : subscriptionFeatures(s),
            badge: AppStrings.subCurrentPlan.tr(),
            highlighted: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, color: AppColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text('$label :', style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
