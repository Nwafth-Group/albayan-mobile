
// ============================================
// FILE: lib/fatures/issues/data/models/issue_detail_model.dart
// ============================================

class IssueDetailModel {
  final String id;
  final int issueNumber;
  final String title;
  final DateTime? publishedAt;
  final num price;
  final bool isFree;
  final String accessState;
  final bool individualPurchaseAllowed;
  final bool isFavorite;
  final bool isBought;

  // Hijri
  final int hYear;
  final int hMonthNumber;
  final String hMonthNameAr;
  final String hMonthNameEn;

  // Gregorian
  final int gYear;
  final int gMonthNumber;
  final String gMonthNameAr;
  final String gMonthNameEn;

  final String? coverImage;
  final int articlesCount;

  final ShortIntroduction? shortIntroduction;
  final List<IndexPreviewItem> indexPreview;

  const IssueDetailModel({
    required this.id,
    required this.issueNumber,
    required this.title,
    required this.publishedAt,
    required this.price,
    required this.isFree,
    required this.accessState,
    required this.individualPurchaseAllowed,
    required this.isFavorite,
    required this.isBought,
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
    required this.shortIntroduction,
    required this.indexPreview,
  });

  factory IssueDetailModel.fromJson(Map<String, dynamic> json) {
    final rawIndex = (json['index_preview'] as List?) ?? const [];
    return IssueDetailModel(
      id: json['id']?.toString() ?? '',
      issueNumber: _toInt(json['issue_number']),
      title: json['title']?.toString() ?? '',
      publishedAt: _toDate(json['published_at']),
      price: (json['price'] is num) ? json['price'] as num : 0,
      isFree: json['is_free'] == true,
      accessState: json['access_state']?.toString() ?? '',
      individualPurchaseAllowed: json['individual_purchase_allowed'] == true,
      isFavorite: json['is_favorite'] == true,
      isBought: json['is_bought'] == true,
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
      shortIntroduction: json['short_introduction'] is Map<String, dynamic>
          ? ShortIntroduction.fromJson(json['short_introduction'])
          : null,
      indexPreview: rawIndex
          .whereType<Map<String, dynamic>>()
          .map(IndexPreviewItem.fromJson)
          .toList(),
    );
  }

  IssueDetailModel copyWith({bool? isFavorite, bool? isBought}) {
    return IssueDetailModel(
      id: id,
      issueNumber: issueNumber,
      title: title,
      publishedAt: publishedAt,
      price: price,
      isFree: isFree,
      accessState: accessState,
      individualPurchaseAllowed: individualPurchaseAllowed,
      isFavorite: isFavorite ?? this.isFavorite,
      isBought: isBought ?? this.isBought,
      hYear: hYear,
      hMonthNumber: hMonthNumber,
      hMonthNameAr: hMonthNameAr,
      hMonthNameEn: hMonthNameEn,
      gYear: gYear,
      gMonthNumber: gMonthNumber,
      gMonthNameAr: gMonthNameAr,
      gMonthNameEn: gMonthNameEn,
      coverImage: coverImage,
      articlesCount: articlesCount,
      shortIntroduction: shortIntroduction,
      indexPreview: indexPreview,
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

class ShortIntroduction {
  final String title;
  final String summary;

  const ShortIntroduction({required this.title, required this.summary});

  factory ShortIntroduction.fromJson(Map<String, dynamic> json) {
    return ShortIntroduction(
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
    );
  }
}

class IndexPreviewItem {
  final IndexCorner? corner;
  final IndexArticle? article;
  final IndexAuthor? author;

  const IndexPreviewItem({this.corner, this.article, this.author});

  factory IndexPreviewItem.fromJson(Map<String, dynamic> json) {
    return IndexPreviewItem(
      corner: json['corner'] is Map<String, dynamic>
          ? IndexCorner.fromJson(json['corner'])
          : null,
      article: json['article'] is Map<String, dynamic>
          ? IndexArticle.fromJson(json['article'])
          : null,
      author: json['author'] is Map<String, dynamic>
          ? IndexAuthor.fromJson(json['author'])
          : null,
    );
  }
}

class IndexCorner {
  final String id;
  final String name;

  const IndexCorner({required this.id, required this.name});

  factory IndexCorner.fromJson(Map<String, dynamic> json) => IndexCorner(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );
}

class IndexArticle {
  final String id;
  final String title;
  final String? image;

  const IndexArticle({required this.id, required this.title, this.image});

  factory IndexArticle.fromJson(Map<String, dynamic> json) => IndexArticle(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    image: json['image']?.toString(),
  );
}

class IndexAuthor {
  final String id;
  final String title;
  final String name;

  const IndexAuthor({
    required this.id,
    required this.title,
    required this.name,
  });

  factory IndexAuthor.fromJson(Map<String, dynamic> json) => IndexAuthor(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );

  /// "Dr. Ahmed Al-Faisal"
  String get displayName =>
      [title, name].where((e) => e.isNotEmpty).join(' ').trim();
}