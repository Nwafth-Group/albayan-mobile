// ============================================
// FILE: lib/fatures/home/data/models/home_section_model.dart
// ============================================
//
// Parses `GET /public/home-sections/{id}/content`:
// { "data": { "section": {...}, "items": [...] } }
//
// `section.type` picks which of the typed item lists below gets filled in;
// an unrecognized/`custom` type is kept as raw JSON in [HomeSectionModel.rawItems]
// since its shape wasn't documented.

import 'package:albayan/utils/constants.dart';

num _num(dynamic v) {
  if (v is num) return v;
  return num.tryParse(v?.toString() ?? '') ?? 0;
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toLocal();
}

/// One entry of `GET /public/home-sections` → `data.items`:
/// `{ "id", "type", "endpoint_url" }`.
class HomeSectionRef {
  final String id;
  final String type;

  /// Path to request with ApiService — relative to the API base url when
  /// the backend's `endpoint_url` lives there, else the absolute url as-is.
  final String endpoint;

  const HomeSectionRef({
    required this.id,
    required this.type,
    required this.endpoint,
  });

  factory HomeSectionRef.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final url = json['endpoint_url']?.toString().trim() ?? '';
    String endpoint;
    if (url.isEmpty) {
      endpoint = '/public/home-sections/$id/content';
    } else if (url.startsWith(ApiConstants.baseUrl)) {
      endpoint = url.substring(ApiConstants.baseUrl.length);
    } else {
      endpoint = url;
    }
    return HomeSectionRef(
      id: id,
      type: json['type']?.toString() ?? '',
      endpoint: endpoint,
    );
  }
}

/// The `section` object every home-section content response includes.
class HomeSectionMeta {
  final String id;
  final String sectionKey;
  final String title;
  final String? subtitle;

  /// `ad_banner` | `corners` | `issues` | `articles` | `books` | `custom` | ...
  final String type;
  final String? subContentType;
  final String? viewType;
  final bool showSeeAll;

  const HomeSectionMeta({
    required this.id,
    required this.sectionKey,
    required this.title,
    this.subtitle,
    required this.type,
    this.subContentType,
    this.viewType,
    this.showSeeAll = false,
  });

  static const empty = HomeSectionMeta(
    id: '',
    sectionKey: '',
    title: '',
    type: '',
  );

  factory HomeSectionMeta.fromJson(Map<String, dynamic> json) {
    return HomeSectionMeta(
      id: json['id']?.toString() ?? '',
      sectionKey: json['section_key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      type: json['type']?.toString() ?? '',
      subContentType: json['sub_content_type']?.toString(),
      viewType: json['view_type']?.toString(),
      showSeeAll: json['show_see_all'] == true,
    );
  }
}

/// One `ad_banner` item.
class HomeBannerItem {
  final String id;
  final String title;
  final String? text;

  /// What `itemIds` refers to — `general` | `books` | `corners` | `articles`
  /// | `issues` (only `books`/`corners` have been seen with a non-empty
  /// `item_ids` so far).
  final String itemType;
  final String? image;
  final String? linkUrl;
  final List<String> itemIds;

  const HomeBannerItem({
    required this.id,
    required this.title,
    this.text,
    required this.itemType,
    this.image,
    this.linkUrl,
    this.itemIds = const [],
  });

  String? get firstItemId => itemIds.isNotEmpty ? itemIds.first : null;

  factory HomeBannerItem.fromJson(Map<String, dynamic> json) {
    final rawIds = json['item_ids'];
    return HomeBannerItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString(),
      itemType: json['type']?.toString() ?? 'general',
      image: json['image']?.toString(),
      linkUrl: json['link_url']?.toString(),
      itemIds: rawIds is List
          ? rawIds.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

/// One `corners` item.
class HomeCornerItem {
  final String id;
  final String name;
  final String? image;
  final String? header;
  final int articlesCount;

  const HomeCornerItem({
    required this.id,
    required this.name,
    this.image,
    this.header,
    this.articlesCount = 0,
  });

  factory HomeCornerItem.fromJson(Map<String, dynamic> json) {
    return HomeCornerItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      header: json['header']?.toString(),
      articlesCount: _int(json['articles_count']),
    );
  }
}

/// One `issues` item.
class HomeIssueItem {
  final String id;
  final int issueNumber;
  final String title;
  final DateTime? publishedAt;
  final num? price;
  final num? finalPrice;
  final bool isFree;
  final String? coverImage;
  final int articlesCount;
  final bool isFavorite;
  final bool isOwned;

  const HomeIssueItem({
    required this.id,
    required this.issueNumber,
    required this.title,
    this.publishedAt,
    this.price,
    this.finalPrice,
    this.isFree = false,
    this.coverImage,
    this.articlesCount = 0,
    this.isFavorite = false,
    this.isOwned = false,
  });

  num get effectivePrice => finalPrice ?? price ?? 0;

  factory HomeIssueItem.fromJson(Map<String, dynamic> json) {
    return HomeIssueItem(
      id: json['id']?.toString() ?? '',
      issueNumber: _int(json['issue_number']),
      title: json['title']?.toString() ?? '',
      publishedAt: _date(json['published_at']),
      price: json['price'] == null ? null : _num(json['price']),
      finalPrice: json['final_price'] == null
          ? null
          : _num(json['final_price']),
      isFree: json['is_free'] == true,
      coverImage: json['cover_image']?.toString(),
      articlesCount: _int(json['articles_count']),
      isFavorite: json['is_favorite'] == true,
      isOwned: json['is_owned'] == true,
    );
  }
}

/// One `articles` item (used by both the "articles" and "fresh_news"
/// sections — they share the exact same item shape).
class HomeArticleItem {
  final String id;
  final String title;
  final String? author;
  final int? issueNumber;
  final num price;
  final num? finalPrice;
  final String? image;
  final DateTime? publishedAt;
  final double rate;
  final bool isFavorite;
  final bool isOwned;

  const HomeArticleItem({
    required this.id,
    required this.title,
    this.author,
    this.issueNumber,
    this.price = 0,
    this.finalPrice,
    this.image,
    this.publishedAt,
    this.rate = 0,
    this.isFavorite = false,
    this.isOwned = false,
  });

  num get effectivePrice => finalPrice ?? price;
  bool get isFree => effectivePrice <= 0;

  factory HomeArticleItem.fromJson(Map<String, dynamic> json) {
    return HomeArticleItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString(),
      issueNumber: json['issue_number'] == null
          ? null
          : _int(json['issue_number']),
      price: _num(json['price']),
      finalPrice: json['final_price'] == null
          ? null
          : _num(json['final_price']),
      image: json['image']?.toString(),
      publishedAt: _date(json['published_at']),
      rate: _num(json['rate']).toDouble(),
      isFavorite: json['is_favorite'] == true,
      isOwned: json['is_owned'] == true,
    );
  }
}

/// One `books` item.
class HomeBookItem {
  /// The id to open `BookScreen` / call the book details API with.
  final String id;

  /// `book_id` — the parent book record; not used for book details.
  final String bookId;

  final String name;
  final String? image;
  final String author;
  final num price;
  final num? finalPrice;
  final double rate;
  final int rateCount;
  final bool isFavorite;
  final bool isOwned;
  final bool isFree;

  const HomeBookItem({
    required this.id,
    required this.bookId,
    required this.name,
    this.image,
    this.author = '',
    this.price = 0,
    this.finalPrice,
    this.rate = 0,
    this.rateCount = 0,
    this.isFavorite = false,
    this.isOwned = false,
    this.isFree = false,
  });

  num get effectivePrice => finalPrice ?? price;

  factory HomeBookItem.fromJson(Map<String, dynamic> json) {
    return HomeBookItem(
      id: json['id']?.toString() ?? '',
      bookId: json['book_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      author: json['author']?.toString() ?? '',
      price: _num(json['price']),
      finalPrice: json['final_price'] == null
          ? null
          : _num(json['final_price']),
      rate: _num(json['rate']).toDouble(),
      rateCount: _int(json['rate_count']),
      isFavorite: json['is_favorite'] == true,
      isOwned: json['is_owned'] == true,
      isFree: json['is_free'] == true,
    );
  }
}

/// One `writers_authors` item.
class HomeAuthorItem {
  /// The author id — opens `AuthorScreen` (`/public/authors/{id}`).
  final String id;
  final String name;
  final String? nickname;
  final String? image;

  /// What they write: `articles` | `books` | `both`.
  final String type;
  final int booksCount;
  final int articlesCount;

  const HomeAuthorItem({
    required this.id,
    required this.name,
    this.nickname,
    this.image,
    this.type = 'both',
    this.booksCount = 0,
    this.articlesCount = 0,
  });

  factory HomeAuthorItem.fromJson(Map<String, dynamic> json) {
    return HomeAuthorItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      image: json['image']?.toString(),
      type: json['type']?.toString() ?? 'both',
      booksCount: _int(json['books_count']),
      articlesCount: _int(json['articles_count']),
    );
  }
}

class HomeSectionModel {
  final HomeSectionMeta meta;
  final List<HomeBannerItem> banners;
  final List<HomeCornerItem> corners;
  final List<HomeIssueItem> issues;
  final List<HomeArticleItem> articles;
  final List<HomeBookItem> books;
  final List<HomeAuthorItem> authors;

  /// Items of a `type` this model doesn't know how to parse yet (e.g.
  /// `custom`) — kept as raw JSON so nothing is lost, just not rendered.
  final List<Map<String, dynamic>> rawItems;

  const HomeSectionModel({
    required this.meta,
    this.banners = const [],
    this.corners = const [],
    this.issues = const [],
    this.articles = const [],
    this.books = const [],
    this.authors = const [],
    this.rawItems = const [],
  });

  bool get isEmpty =>
      banners.isEmpty &&
      corners.isEmpty &&
      issues.isEmpty &&
      articles.isEmpty &&
      books.isEmpty &&
      authors.isEmpty &&
      rawItems.isEmpty;

  factory HomeSectionModel.fromJson(Map<String, dynamic> data) {
    final sectionJson = data['section'];
    final meta = sectionJson is Map<String, dynamic>
        ? HomeSectionMeta.fromJson(sectionJson)
        : HomeSectionMeta.empty;

    final rawList = data['items'];
    final items = rawList is List
        ? rawList.whereType<Map<String, dynamic>>().toList()
        : const <Map<String, dynamic>>[];

    switch (meta.type) {
      case 'ad_banner':
        return HomeSectionModel(
          meta: meta,
          banners: items.map(HomeBannerItem.fromJson).toList(),
        );
      case 'corners':
        return HomeSectionModel(
          meta: meta,
          corners: items.map(HomeCornerItem.fromJson).toList(),
        );
      case 'issues':
        return HomeSectionModel(
          meta: meta,
          issues: items.map(HomeIssueItem.fromJson).toList(),
        );
      case 'articles':
        return HomeSectionModel(
          meta: meta,
          articles: items.map(HomeArticleItem.fromJson).toList(),
        );
      case 'books':
        return HomeSectionModel(
          meta: meta,
          books: items.map(HomeBookItem.fromJson).toList(),
        );
      case 'writers_authors':
        return HomeSectionModel(
          meta: meta,
          authors: items
              .map(HomeAuthorItem.fromJson)
              // An author without an id couldn't be opened.
              .where((a) => a.id.isNotEmpty)
              .toList(),
        );
      default:
        return HomeSectionModel(meta: meta, rawItems: items);
    }
  }
}
