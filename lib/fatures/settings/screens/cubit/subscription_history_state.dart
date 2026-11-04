// ============================================
// FILE: lib/fatures/settings/screens/cubit/subscription_history_state.dart
// ============================================

part of 'subscription_history_cubit.dart';

enum SubscriptionHistoryStatus {
  initial,
  loading,
  loadingMore,
  success,
  empty,
  failure,
}

class SubscriptionHistoryState extends Equatable {
  final SubscriptionHistoryStatus status;
  final List<UserSubscriptionModel> items;
  final List<SubscriptionPlanModel> plans;
  final PaginationMeta? meta;
  final String? error;

  const SubscriptionHistoryState({
    this.status = SubscriptionHistoryStatus.initial,
    this.items = const [],
    this.plans = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoadingMore => status == SubscriptionHistoryStatus.loadingMore;

  SubscriptionPlanModel? planFor(UserSubscriptionModel sub) {
    for (final p in plans) {
      if (p.id == sub.planId) return p;
    }
    return null;
  }

  SubscriptionHistoryState copyWith({
    SubscriptionHistoryStatus? status,
    List<UserSubscriptionModel>? items,
    List<SubscriptionPlanModel>? plans,
    PaginationMeta? meta,
    String? error,
  }) {
    return SubscriptionHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      plans: plans ?? this.plans,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, plans, meta, error];
}
