// ============================================
// FILE: lib/fatures/settings/data/models/subscription_model.dart
// ============================================
//
// Subscription plans (`GET /public/subscriptions/plans`) and the reader's
// own subscriptions (`/reader/subscriptions/current|history|purchase`).

/// Lifecycle of a reader subscription, from the backend's `status` string.
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending;

  static SubscriptionStatus parse(Object? raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'active':
      case 'trial':
      case 'trialing':
      case 'in_trial':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
      case 'canceled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.pending;
    }
  }
}

/// Picks the [languageCode] entry of a `{ar, en}` map, falling back to
/// [translated] and then any non-empty value.
String _localized(Object? map, String languageCode, Object? translated) {
  if (map is Map) {
    final value = map[languageCode]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  final t = translated?.toString();
  if (t != null && t.isNotEmpty) return t;
  if (map is Map) {
    for (final v in map.values) {
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
  }
  return map is String ? map : '';
}

int _toInt(Object? v) =>
    v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

num? _toNum(Object? v) => v is num ? v : num.tryParse(v?.toString() ?? '');

DateTime? _toDate(Object? v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

bool _toBool(Object? v) => v == true || v == 1 || v == '1' || v == 'true';

class SubscriptionPlanModel {
  final String id;
  final String? versionId;
  final String name;
  final String description;

  /// quarterly | semi_annual | annual | monthly ...
  final String duration;
  final int durationMonths;
  final num price;
  final String currency;
  final int coveredIssueCount;
  final bool hasArchiveAccess;
  final List<String> platforms;
  final String? appleProductId;
  final String? googleProductId;
  final bool hasTrial;
  final int trialDurationDays;
  final bool isAutoRenew;

  const SubscriptionPlanModel({
    required this.id,
    this.versionId,
    required this.name,
    this.description = '',
    required this.duration,
    required this.durationMonths,
    required this.price,
    this.currency = 'SAR',
    this.coveredIssueCount = 0,
    this.hasArchiveAccess = false,
    this.platforms = const [],
    this.appleProductId,
    this.googleProductId,
    this.hasTrial = false,
    this.trialDurationDays = 0,
    this.isAutoRenew = false,
  });

  factory SubscriptionPlanModel.fromJson(
    Map<String, dynamic> json, {
    required String languageCode,
  }) {
    final platforms = json['platforms'];
    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      versionId: json['version_id']?.toString(),
      name: _localized(json['name'], languageCode, json['name_translated']),
      description: _localized(
        json['description'],
        languageCode,
        json['description_translated'],
      ),
      duration: json['duration']?.toString() ?? '',
      durationMonths: _toInt(json['duration_months']),
      price: _toNum(json['price']) ?? 0,
      currency: json['currency']?.toString() ?? 'SAR',
      coveredIssueCount: _toInt(json['covered_issue_count']),
      hasArchiveAccess: _toBool(json['has_archive_access']),
      platforms: platforms is List
          ? platforms.map((e) => e.toString()).toList()
          : const [],
      appleProductId: json['apple_product_id']?.toString(),
      googleProductId: json['google_product_id']?.toString(),
      hasTrial: _toBool(json['has_trial']),
      trialDurationDays: _toInt(json['trial_duration_days']),
      isAutoRenew: _toBool(json['is_auto_renew']),
    );
  }
}

/// One of the reader's subscriptions — the shape returned by `current`,
/// `history` and `purchase` (the latter nests the plan in `plan_version`).
class UserSubscriptionModel {
  final String id;
  final String planId;
  final String planName;
  final String duration;
  final int durationMonths;
  final String? platform;
  final SubscriptionStatus status;
  final bool isAutoRenew;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? renewalDate;
  final int remainingDays;
  final int coveredIssueCount;
  final bool hasArchiveAccess;

  /// Only present when the payload embeds the plan (`plan_version`/`price`).
  final num? price;
  final String? currency;

  const UserSubscriptionModel({
    required this.id,
    required this.planId,
    required this.planName,
    required this.duration,
    required this.durationMonths,
    this.platform,
    required this.status,
    required this.isAutoRenew,
    this.startDate,
    this.endDate,
    this.renewalDate,
    this.remainingDays = 0,
    this.coveredIssueCount = 0,
    this.hasArchiveAccess = false,
    this.price,
    this.currency,
  });

  bool get isActive => status == SubscriptionStatus.active;

  factory UserSubscriptionModel.fromJson(
    Map<String, dynamic> json, {
    required String languageCode,
  }) {
    final plan = json['plan_version'] is Map<String, dynamic>
        ? json['plan_version'] as Map<String, dynamic>
        : json['plan'] is Map<String, dynamic>
        ? json['plan'] as Map<String, dynamic>
        : const <String, dynamic>{};
    Object? pick(String key) => json[key] ?? plan[key];

    final rawName = json['plan_name'];
    return UserSubscriptionModel(
      id: json['id']?.toString() ?? '',
      planId:
          (json['plan_id'] ??
                  json['subscription_plan_id'] ??
                  plan['subscription_plan_id'] ??
                  '')
              .toString(),
      planName: rawName is String && rawName.isNotEmpty
          ? rawName
          : _localized(
              rawName ?? plan['name'],
              languageCode,
              plan['name_translated'],
            ),
      duration: pick('duration')?.toString() ?? '',
      durationMonths: _toInt(pick('duration_months')),
      platform: json['platform']?.toString(),
      status: SubscriptionStatus.parse(json['status']),
      isAutoRenew: _toBool(json['is_auto_renew']),
      startDate: _toDate(json['start_date']),
      endDate: _toDate(json['end_date']),
      renewalDate: _toDate(json['renewal_date']),
      remainingDays: (_toNum(json['remaining_days']) ?? 0).floor(),
      coveredIssueCount: _toInt(pick('covered_issue_count')),
      hasArchiveAccess: _toBool(pick('has_archive_access')),
      price: _toNum(pick('price')),
      currency: pick('currency')?.toString(),
    );
  }
}
