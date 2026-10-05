// ============================================
// FILE: lib/fatures/settings/data/models/subscription_model.dart
// ============================================
//
// View model for My Subscriptions.
//
// TODO(api): there is no subscriptions endpoint yet — the profile only
// exposes `have_subscription` / `subscription_status`, so the plan details
// come from [SubscriptionModel.sample] until one exists.

class SubscriptionModel {
  final String planName;
  final int durationMonths;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? autoRenewalDate;
  final bool renews;
  final num price;

  /// Price before an offer, shown struck through when set.
  final num? oldPrice;

  final List<String> features;

  const SubscriptionModel({
    required this.planName,
    required this.durationMonths,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.autoRenewalDate,
    required this.renews,
    required this.price,
    this.oldPrice,
    this.features = const [],
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  static final sample = SubscriptionModel(
    planName: 'Premium',
    durationMonths: 12,
    isActive: true,
    startDate: DateTime(2025, 9, 9),
    endDate: DateTime(2026, 9, 9),
    autoRenewalDate: DateTime(2026, 9, 9),
    renews: true,
    price: 2930.5,
    oldPrice: 3930.5,
    features: const [
      '12 Paid issues during the period',
      'Full archive access',
      '12 Paid issues during the period',
      '12 Paid issues during the period',
      '12 Paid issues during the period',
    ],
  );
}
