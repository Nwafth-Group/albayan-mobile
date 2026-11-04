// ============================================
// FILE: lib/fatures/library/data/models/personal_category_model.dart
// ============================================
//
// Parses:
//  - `GET /reader/personal-categories`
//    { "data": { "items": [ { "id", "name", "type", "counts": { "books",
//      "issues", "articles", "total" }, "items_count", "created_at" } ] } }
//  - `GET /reader/personal-categories/{id}/items?type=book|issue|article&page=`
//    { "data": { "items": [...], "meta": {...} } }
//    (item shape wasn't documented — parsed defensively)

import '../../../issues/data/models/pagination_meta.dart';
import 'library_article_model.dart';
import 'library_book_model.dart';
import 'library_issue_model.dart';

/// Values accepted by the items endpoint's `type` query param.
enum PersonalCategoryType {
  book('book'),
  issue('issue'),
  article('article');

  final String value;
  const PersonalCategoryType(this.value);
}

int _parseInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

class PersonalCategoryModel {
  final String id;
  final String name;
  final String type;
  final int booksCount;
  final int issuesCount;
  final int articlesCount;
  final int itemsCount;
  final DateTime? createdAt;

  const PersonalCategoryModel({
    required this.id,
    required this.name,
    this.type = '',
    this.booksCount = 0,
    this.issuesCount = 0,
    this.articlesCount = 0,
    this.itemsCount = 0,
    this.createdAt,
  });

  factory PersonalCategoryModel.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] is Map<String, dynamic>
        ? json['counts'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return PersonalCategoryModel(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['title'])?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      booksCount: _parseInt(counts['books'] ?? json['books_count']),
      issuesCount: _parseInt(counts['issues'] ?? json['issues_count']),
      articlesCount: _parseInt(counts['articles'] ?? json['articles_count']),
      itemsCount: _parseInt(json['items_count'] ?? counts['total']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
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

/// One book / issue / article saved in a personal category.
class PersonalCategoryItem {
  final PersonalCategoryType type;
  final LibraryBookModel? book;
  final LibraryIssueModel? issue;
  final LibraryArticleModel? article;

  const PersonalCategoryItem._(
    this.type, {
    this.book,
    this.issue,
    this.article,
  });

  const PersonalCategoryItem.book(LibraryBookModel this.book)
    : type = PersonalCategoryType.book,
      issue = null,
      article = null;

  const PersonalCategoryItem.issue(LibraryIssueModel this.issue)
    : type = PersonalCategoryType.issue,
      book = null,
      article = null;

  const PersonalCategoryItem.article(LibraryArticleModel this.article)
    : type = PersonalCategoryType.article,
      book = null,
      issue = null;

  String get id => book?.id ?? issue?.id ?? article?.id ?? '';

  factory PersonalCategoryItem.fromJson(
    Map<String, dynamic> json,
    PersonalCategoryType type,
  ) {
    // The content may come wrapped (e.g. `{ "item": {...} }` or
    // `{ "book": {...} }`) or flat.
    var content = json;
    for (final key in [type.value, 'item', 'itemable', 'content']) {
      final nested = json[key];
      if (nested is Map<String, dynamic>) {
        content = nested;
        break;
      }
    }
    if (content['id'] == null && json['item_id'] != null) {
      content = {...content, 'id': json['item_id']};
    }

    switch (type) {
      case PersonalCategoryType.book:
        return PersonalCategoryItem._(
          type,
          book: LibraryBookModel.fromJson(content),
        );
      case PersonalCategoryType.issue:
        return PersonalCategoryItem._(
          type,
          issue: LibraryIssueModel.fromJson(content),
        );
      case PersonalCategoryType.article:
        return PersonalCategoryItem._(
          type,
          article: LibraryArticleModel.fromJson(content),
        );
    }
  }
}

class PersonalCategoryItemsResponse {
  final List<PersonalCategoryItem> items;
  final PaginationMeta meta;

  const PersonalCategoryItemsResponse({
    required this.items,
    required this.meta,
  });

  /// Parses the `data` object: `{ "items": [...], "meta": {...} }`.
  factory PersonalCategoryItemsResponse.fromData(
    dynamic data,
    PersonalCategoryType type,
  ) {
    final map = data is Map<String, dynamic> ? data : const {};
    final rawItems = map['items'];
    final items = (rawItems is List)
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map((e) => PersonalCategoryItem.fromJson(e, type))
              .toList()
        : <PersonalCategoryItem>[];

    final rawMeta = map['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return PersonalCategoryItemsResponse(items: items, meta: meta);
  }
}
