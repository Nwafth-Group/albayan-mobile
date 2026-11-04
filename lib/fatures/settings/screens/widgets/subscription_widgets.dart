// ============================================
// FILE: lib/fatures/settings/screens/widgets/subscription_widgets.dart
// ============================================
//
// Pieces shared by My Subscriptions, the Upgrade Plan sheet and History:
// the price/features plan card, its corner badge, and the sheet itself.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/custom_button.dart';
import '../../data/models/subscription_model.dart';
import '../cubit/subscriptions_cubit.dart';
import 'settings_widgets.dart';

/// Dark pill used for "Expired" badges in the designs.
const Color subscriptionExpiredBadge = Color(0xFF2B2B33);

/// "Quarterly" / "Semi-Annual" / "Annual", or "{n} Month" for anything else.
String subscriptionDurationLabel(String duration, int months) {
  switch (duration) {
    case 'monthly':
      return AppStrings.planMonthly.tr();
    case 'quarterly':
      return AppStrings.planQuarterly.tr();
    case 'semi_annual':
      return AppStrings.planSemiAnnual.tr();
    case 'annual':
    case 'yearly':
      return AppStrings.planAnnual.tr();
  }
  return AppStrings.monthsCount.tr(namedArgs: {'count': '$months'});
}

String subscriptionStatusLabel(SubscriptionStatus status) => switch (status) {
  SubscriptionStatus.active => AppStrings.subActive.tr(),
  SubscriptionStatus.expired => AppStrings.subExpired.tr(),
  SubscriptionStatus.cancelled => AppStrings.subCancelled.tr(),
  SubscriptionStatus.pending => AppStrings.subPending.tr(),
};

String subscriptionCurrency(String? code) =>
    code == null || code.toUpperCase() == 'SAR'
    ? AppStrings.currencySar.tr()
    : code;

class PlanFeature {
  final String text;
  final bool included;
  const PlanFeature(this.text, {this.included = true});
}

/// The check / cross feature list of a plan, built from its API fields.
List<PlanFeature> planFeatures(SubscriptionPlanModel plan) {
  const platformNames = {'ios': 'iOS', 'android': 'Android', 'web': 'Web'};
  return [
    PlanFeature(
      AppStrings.subFeatureIssues.tr(
        namedArgs: {'count': '${plan.coveredIssueCount}'},
      ),
    ),
    PlanFeature(
      AppStrings.subFeatureArchive.tr(),
      included: plan.hasArchiveAccess,
    ),
    PlanFeature(
      plan.hasTrial
          ? AppStrings.subFeatureTrial.tr(
              namedArgs: {'days': '${plan.trialDurationDays}'},
            )
          : AppStrings.subFeatureNoTrial.tr(),
      included: plan.hasTrial,
    ),
    PlanFeature(
      AppStrings.subFeatureAutoRenew.tr(),
      included: plan.isAutoRenew,
    ),
    if (plan.platforms.isNotEmpty)
      PlanFeature(
        AppStrings.subFeaturePlatforms.tr(
          namedArgs: {
            'platforms': plan.platforms
                .map((p) => platformNames[p] ?? p)
                .join(', '),
          },
        ),
      ),
  ];
}

/// Features of a subscription whose plan isn't in the plans list.
List<PlanFeature> subscriptionFeatures(UserSubscriptionModel sub) => [
  PlanFeature(
    AppStrings.subFeatureIssues.tr(
      namedArgs: {'count': '${sub.coveredIssueCount}'},
    ),
  ),
  PlanFeature(AppStrings.subFeatureArchive.tr(), included: sub.hasArchiveAccess),
  PlanFeature(AppStrings.subFeatureAutoRenew.tr(), included: sub.isAutoRenew),
];

/// Price, period and features with a corner badge — the card used for
/// plans and subscriptions throughout the designs.
///
/// [highlighted] draws the peach background with the maroon border (the
/// selected / active card); otherwise it's a plain white card.
class SubscriptionPlanCard extends StatelessWidget {
  final num? price;
  final String? currency;
  final String period;

  /// Shown instead of the price when it's unknown.
  final String? title;
  final List<PlanFeature> features;
  final String? badge;
  final Color badgeColor;
  final bool highlighted;
  final VoidCallback? onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.price,
    this.currency,
    required this.period,
    this.title,
    required this.features,
    this.badge,
    this.badgeColor = AppColors.primary,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat('#,##0.##');

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: highlighted
          ? BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.5),
            )
          : settingsCard(),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  price != null
                      ? '${subscriptionCurrency(currency)} ${amount.format(price)}'
                      : (title ?? ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: price != null ? 22 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                for (final f in features)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          f.included ? Icons.check : Icons.close,
                          size: 16,
                          color: f.included
                              ? AppColors.primary
                              : AppColors.textLight,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            f.text,
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
          if (badge != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: const BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(10),
                  ),
                ),
                child: Text(
                  badge!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

/// Card for one of the reader's subscriptions (History) — the active one
/// is highlighted, the others are plain with a dark "Expired" badge.
class UserSubscriptionCard extends StatelessWidget {
  final UserSubscriptionModel subscription;
  final SubscriptionPlanModel? plan;

  const UserSubscriptionCard({
    super.key,
    required this.subscription,
    this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    return SubscriptionPlanCard(
      price: s.price ?? plan?.price,
      currency: s.currency ?? plan?.currency,
      title: s.planName,
      period: subscriptionDurationLabel(s.duration, s.durationMonths),
      features: plan != null ? planFeatures(plan!) : subscriptionFeatures(s),
      badge: subscriptionStatusLabel(s.status),
      badgeColor: s.isActive ? AppColors.primary : subscriptionExpiredBadge,
      highlighted: s.isActive,
    );
  }
}

/// Upgrade Plan sheet: lists the plans from the [SubscriptionsCubit] in
/// [context], lets the reader pick one and purchases it.
///
/// Returns true when a plan was purchased.
Future<bool?> showUpgradePlanSheet(BuildContext context) {
  final cubit = context.read<SubscriptionsCubit>();
  if (cubit.state.plans.isEmpty) cubit.loadPlans();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _UpgradePlanSheet()),
  );
}

class _UpgradePlanSheet extends StatefulWidget {
  const _UpgradePlanSheet();

  @override
  State<_UpgradePlanSheet> createState() => _UpgradePlanSheetState();
}

class _UpgradePlanSheetState extends State<_UpgradePlanSheet> {
  String? _selectedId;

  Future<void> _purchase(SubscriptionPlanModel plan) async {
    final ok = await context.read<SubscriptionsCubit>().purchase(plan);
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.subPurchaseSuccess.tr()),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
            builder: (context, state) {
              final current = state.current;
              final hasActive = current?.isActive ?? false;
              final available = state.plans
                  .where((p) => !(hasActive && p.id == current!.planId))
                  .toList();
              final selectedId =
                  _selectedId ??
                  (available.isNotEmpty ? available.first.id : null);
              SubscriptionPlanModel? selected;
              for (final p in available) {
                if (p.id == selectedId) selected = p;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    (hasActive
                            ? AppStrings.upgradePlanTitle
                            : AppStrings.choosePlanTitle)
                        .tr(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppStrings.upgradePlanDesc.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: state.plans.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: state.status == SubscriptionsStatus.loading
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  )
                                : Text(
                                    AppStrings.noPlansAvailable.tr(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            itemCount: state.plans.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final plan = state.plans[i];
                              final isCurrent =
                                  hasActive && plan.id == current!.planId;
                              return Opacity(
                                opacity: isCurrent ? 0.6 : 1,
                                child: SubscriptionPlanCard(
                                  price: plan.price,
                                  currency: plan.currency,
                                  period: subscriptionDurationLabel(
                                    plan.duration,
                                    plan.durationMonths,
                                  ),
                                  features: planFeatures(plan),
                                  badge: isCurrent
                                      ? AppStrings.subCurrentPlan.tr()
                                      : plan.name,
                                  badgeColor: isCurrent
                                      ? subscriptionExpiredBadge
                                      : AppColors.primary,
                                  highlighted: plan.id == selectedId,
                                  onTap: isCurrent || state.isPurchasing
                                      ? null
                                      : () => setState(
                                          () => _selectedId = plan.id,
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: CustomButton(
                        text:
                            (hasActive
                                    ? AppStrings.subUpgrade
                                    : AppStrings.subscribeNow)
                                .tr(),
                        isLoading: state.isPurchasing,
                        onPressed: selected == null || state.isPurchasing
                            ? null
                            : () => _purchase(selected!),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
