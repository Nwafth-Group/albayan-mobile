
// ============================================
// FILE: lib/fatures/search/data/models/search_initial_model.dart
// ============================================
//
// Parses `GET /public/search/initial`, the default content shown on the
// Search tab before the user types anything: recent searches, trending
// keywords, and a "Fresh Articles" style discovery feed.

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';

class RecentSearchModel {
  final String id;
  final String query;
  final DateTime? lastSearchedAt;

  const RecentSearchModel({
    required this.id,
    required this.query,
    this.lastSearchedAt,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      id: json['id']?.toString() ?? '',
      query: json['query']?.toString() ?? '',
      lastSearchedAt: json['last_searched_at'] == null
          ? null
          : DateTime.tryParse(json['last_searched_at'].toString()),
    );
  }
}

class TrendingKeywordModel {
  final String id;
  final String name;

  const TrendingKeywordModel({required this.id, required this.name});

  factory TrendingKeywordModel.fromJson(Map<String, dynamic> json) {
    return TrendingKeywordModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class SearchInitialModel {
  final List<RecentSearchModel> recentSearches;
  final List<TrendingKeywordModel> trendingKeywords;
  final List<CornerArticleModel> discoveryArticles;

  const SearchInitialModel({
    this.recentSearches = const [],
    this.trendingKeywords = const [],
    this.discoveryArticles = const [],
  });

  static const empty = SearchInitialModel();

  factory SearchInitialModel.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recent_searches'];
    final rawTrending = json['trending_keywords'];
    final rawArticles = json['discovery_articles'];

    return SearchInitialModel(
      recentSearches: rawRecent is List
          ? rawRecent
              .whereType<Map<String, dynamic>>()
              .map(RecentSearchModel.fromJson)
              .toList()
          : const [],
      trendingKeywords: rawTrending is List
          ? rawTrending
              .whereType<Map<String, dynamic>>()
              .map(TrendingKeywordModel.fromJson)
              .toList()
          : const [],
      discoveryArticles: rawArticles is List
          ? rawArticles
              .whereType<Map<String, dynamic>>()
              .map(_discoveryArticleFromJson)
              .toList()
          : const [],
    );
  }

  /// The "Fresh Articles" card (`CornerArticleCard`) only needs a flat
  /// shape — map the nested `author`/`corner`/`issue` objects from the
  /// search response into that existing shape so the feed reuses the same
  /// card already used elsewhere in the app.
  static CornerArticleModel _discoveryArticleFromJson(
    Map<String, dynamic> json,
  ) {
    final author = json['author'];
    final issue = json['issue'];
    return CornerArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: author is Map<String, dynamic>
          ? (author['name']?.toString() ?? '')
          : '',
      issueNumber:
          issue is Map<String, dynamic> ? _toInt(issue['issue_number']) : 0,
      price: (json['final_price'] is num)
          ? json['final_price'] as num
          : (json['price'] is num ? json['price'] as num : 0),
      image: json['image']?.toString(),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.tryParse(json['published_at'].toString()),
      rate: (json['rate'] is num)
          ? (json['rate'] as num).toDouble()
          : double.tryParse(json['rate']?.toString() ?? '') ?? 0,
      isFavorite: json['is_favorite'] == true,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
