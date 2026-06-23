
// ============================================
// FILE: lib/fatures/issues/data/models/issue_model.dart
// ============================================

class IssueModel {
  final String id;
  final int issueNumber;
  final String title;
  final DateTime? publishedAt;
  final num price;
  final bool isFree;
  final String accessState; // e.g. "Paid" / "Free"
  final bool individualPurchaseAllowed;

  // Hijri date
  final int hYear;
  final int hMonthNumber;
  final String hMonthNameAr;
  final String hMonthNameEn;

  // Gregorian date
  final int gYear;
  final int gMonthNumber;
  final String gMonthNameAr;
  final String gMonthNameEn;

  final String? coverImage;
  final int articlesCount;

  const IssueModel({
    required this.id,
    required this.issueNumber,
    required this.title,
    required this.publishedAt,
    required this.price,
    required this.isFree,
    required this.accessState,
    required this.individualPurchaseAllowed,
    required this.hYear,
    required this.hMonthNumber,
    required this.hMonthNameAr,
    required this.hMonthNameEn,
    required this.gYear,
    required this.gMonthNumber,
    required this.gMonthNameAr,
    required this.gMonthNameEn,
    required this.coverImage,
    required this.articlesCount,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id']?.toString() ?? '',
      issueNumber: _toInt(json['issue_number']),
      title: json['title']?.toString() ?? '',
      publishedAt: _toDate(json['published_at']),
      price: (json['price'] is num) ? json['price'] as num : 0,
      isFree: json['is_free'] == true,
      accessState: json['access_state']?.toString() ?? '',
      individualPurchaseAllowed: json['individual_purchase_allowed'] == true,
      hYear: _toInt(json['h_year']),
      hMonthNumber: _toInt(json['h_month_number']),
      hMonthNameAr: json['h_month_name_ar']?.toString() ?? '',
      hMonthNameEn: json['h_month_name_en']?.toString() ?? '',
      gYear: _toInt(json['g_year']),
      gMonthNumber: _toInt(json['g_month_number']),
      gMonthNameAr: json['g_month_name_ar']?.toString() ?? '',
      gMonthNameEn: json['g_month_name_en']?.toString() ?? '',
      coverImage: json['cover_image']?.toString(),
      articlesCount: _toInt(json['articles_count']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString())?.toLocal();
  }
}