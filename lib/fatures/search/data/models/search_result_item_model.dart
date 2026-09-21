
// ============================================
// FILE: lib/fatures/search/data/models/search_result_item_model.dart
// ============================================
//
// A single result of `GET /public/search`. Only the `articles` tab shape
// has been confirmed by the backend so far (title/summary/author/corner/
// issue/price/final_price/is_free/image/rate/published_at/is_favorite/
// is_owned). Every field here is nullable/defaulted so the same model
// keeps parsing safely if the `books` / `issues` tabs return a differently
// shaped item.

class SearchResultItemModel {
  final String id;
  final String? versionId;
  final String title;
  final String? summary;
  final String? authorName;
  final String? authorAvatar;
  final String? cornerName;
  final int? issueNumber;
  final num? price;
  final num? finalPrice;
  final bool isFree;
  final String? image;
  final double rate;
  final DateTime? publishedAt;
  final bool isFavorite;
  final bool isOwned;

  const SearchResultItemModel({
    required this.id,
    this.versionId,
    required this.title,
    this.summary,
    this.authorName,
    this.authorAvatar,
    this.cornerName,
    this.issueNumber,
    this.price,
    this.finalPrice,
    this.isFree = false,
    this.image,
    this.rate = 0,
    this.publishedAt,
    this.isFavorite = false,
    this.isOwned = false,
  });

  num get effectivePrice => finalPrice ?? price ?? 0;

  factory SearchResultItemModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    final corner = json['corner'];
    final issue = json['issue'];
    return SearchResultItemModel(
      id: json['id']?.toString() ?? '',
      versionId: json['version_id']?.toString(),
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString(),
      authorName: author is Map<String, dynamic>
          ? author['name']?.toString()
          : author?.toString(),
      authorAvatar:
          author is Map<String, dynamic> ? author['avatar']?.toString() : null,
      cornerName:
          corner is Map<String, dynamic> ? corner['name']?.toString() : null,
      issueNumber:
          issue is Map<String, dynamic> ? _toInt(issue['issue_number']) : null,
      price: json['price'] is num ? json['price'] as num : null,
      finalPrice:
          json['final_price'] is num ? json['final_price'] as num : null,
      isFree: json['is_free'] == true,
      image: json['image']?.toString(),
      rate: (json['rate'] is num)
          ? (json['rate'] as num).toDouble()
          : double.tryParse(json['rate']?.toString() ?? '') ?? 0,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.tryParse(json['published_at'].toString()),
      isFavorite: json['is_favorite'] == true,
      isOwned: json['is_owned'] == true,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class SearchResultCounts {
  final int articles;
  final int books;
  final int issues;

  const SearchResultCounts({
    this.articles = 0,
    this.books = 0,
    this.issues = 0,
  });

  static const empty = SearchResultCounts();

  factory SearchResultCounts.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return SearchResultCounts(
      articles: parse(json['articles']),
      books: parse(json['books']),
      issues: parse(json['issues']),
    );
  }
}
