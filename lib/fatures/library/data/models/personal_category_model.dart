// ============================================
// FILE: lib/fatures/library/data/models/personal_category_model.dart
// ============================================
//
// Parses:
//  - `GET /reader/personal-categories/counts`
//    { "data": { "books_count", "magazine_issues_count",
//                "magazine_articles_count" } }
//  - `GET /reader/personal-categories?type=book|article|issue`
//    (item shape wasn't documented — parsed defensively)

/// Values accepted by the `type` query param.
enum PersonalCategoryType {
  book('book'),
  article('article'),
  issue('issue');

  final String value;
  const PersonalCategoryType(this.value);
}

int _parseInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

class PersonalCategoryCounts {
  final int booksCount;
  final int issuesCount;
  final int articlesCount;

  const PersonalCategoryCounts({
    this.booksCount = 0,
    this.issuesCount = 0,
    this.articlesCount = 0,
  });

  static const empty = PersonalCategoryCounts();

  factory PersonalCategoryCounts.fromJson(Map<String, dynamic> json) {
    return PersonalCategoryCounts(
      booksCount: _parseInt(json['books_count']),
      issuesCount: _parseInt(json['magazine_issues_count']),
      articlesCount: _parseInt(json['magazine_articles_count']),
    );
  }

  int countOf(PersonalCategoryType type) {
    switch (type) {
      case PersonalCategoryType.book:
        return booksCount;
      case PersonalCategoryType.issue:
        return issuesCount;
      case PersonalCategoryType.article:
        return articlesCount;
    }
  }
}

class PersonalCategoryModel {
  final String id;
  final String name;
  final int itemsCount;

  const PersonalCategoryModel({
    required this.id,
    required this.name,
    this.itemsCount = 0,
  });

  factory PersonalCategoryModel.fromJson(Map<String, dynamic> json) {
    return PersonalCategoryModel(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['title'])?.toString() ?? '',
      itemsCount: _parseInt(json['items_count'] ?? json['count']),
    );
  }

  /// `data` may be a bare list or `{ "items": [...] }`.
  static List<PersonalCategoryModel> listFrom(dynamic data) {
    final raw = data is Map<String, dynamic> ? data['items'] : data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PersonalCategoryModel.fromJson)
        .toList();
  }
}
