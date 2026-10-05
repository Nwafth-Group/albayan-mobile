// ============================================
// FILE: lib/fatures/settings/screens/subscriptions_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../../widgets/empty_state.dart';
import '../data/models/subscription_model.dart';
import 'widgets/settings_widgets.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  void _comingSoon() => Helpers.showError(AppStrings.featureComingSoon.tr());

  @override
  Widget build(BuildContext context) {
    final user = SharedPrefHelper.getUser();
    // TODO(api): replace the sample with the real subscription once an
    // endpoint exists; the profile only says whether one is active.
    final SubscriptionModel? subscription = user?.haveSubscription == true
        ? SubscriptionModel.sample
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(
        title: AppStrings.mySubscriptions.tr(),
        actions: [
          IconButton(
            onPressed: _comingSoon,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedShield01,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: _comingSoon,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedWorkHistory,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
      body: subscription == null
          ? EmptyState(
              icon: Icons.workspace_premium_outlined,
              title: AppStrings.noSubscriptionTitle.tr(),
              subtitle: AppStrings.noSubscriptionDesc.tr(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [_SubscriptionCard(subscription: subscription)],
            ),
      bottomNavigationBar: SettingsButtonPair(
        secondaryText: AppStrings.subUpgrade.tr(),
        primaryText: AppStrings.manageSubscription.tr(),
        // TODO(api): upgrade / manage flows (store subscriptions).
        onSecondary: _comingSoon,
        onPrimary: _comingSoon,
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  const _SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy');
    final s = subscription;

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
                  s.planName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (s.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF3E4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.subActive.tr(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF3FA564),
                    ),
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
          _InfoRow(AppStrings.startDate.tr(), date.format(s.startDate)),
          _InfoRow(AppStrings.endDate.tr(), date.format(s.endDate)),
          if (s.autoRenewalDate != null)
            _InfoRow(
              AppStrings.autoRenewal.tr(),
              date.format(s.autoRenewalDate!),
            ),
          _InfoRow(
            AppStrings.renewsOn.tr(),
            (s.renews ? AppStrings.toggleOn : AppStrings.toggleOff).tr(),
          ),
          const SizedBox(height: 14),
          _PlanCard(subscription: s),
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

class _PlanCard extends StatelessWidget {
  final SubscriptionModel subscription;
  const _PlanCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    final amount = NumberFormat('#,##0.##');
    final currency = AppStrings.currencySar.tr();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (s.hasDiscount) ...[
                      Text(
                        amount.format(s.oldPrice),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '$currency ${amount.format(s.price)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  AppStrings.planAnnual.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                for (final feature in s.features)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(10),
                ),
              ),
              child: Text(
                AppStrings.planPremium.tr(),
                style: const TextStyle(fontSize: 10, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
