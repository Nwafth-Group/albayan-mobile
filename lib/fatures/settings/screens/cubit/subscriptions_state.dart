// ============================================
// FILE: lib/fatures/settings/screens/cubit/subscriptions_state.dart
// ============================================

part of 'subscriptions_cubit.dart';

enum SubscriptionsStatus { initial, loading, success, failure }

class SubscriptionsState extends Equatable {
  final SubscriptionsStatus status;
  final UserSubscriptionModel? current;
  final List<SubscriptionPlanModel> plans;
  final bool isPurchasing;
  final String? error;

  const SubscriptionsState({
    this.status = SubscriptionsStatus.initial,
    this.current,
    this.plans = const [],
    this.isPurchasing = false,
    this.error,
  });

  /// The plan the current subscription belongs to, if it's still offered.
  SubscriptionPlanModel? get currentPlan {
    final id = current?.planId;
    if (id == null) return null;
    for (final p in plans) {
      if (p.id == id) return p;
    }
    return null;
  }

  SubscriptionsState copyWith({
    SubscriptionsStatus? status,
    UserSubscriptionModel? current,
    bool clearCurrent = false,
    List<SubscriptionPlanModel>? plans,
    bool? isPurchasing,
    String? error,
  }) {
    return SubscriptionsState(
      status: status ?? this.status,
      current: clearCurrent ? null : (current ?? this.current),
      plans: plans ?? this.plans,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, current, plans, isPurchasing, error];
}
