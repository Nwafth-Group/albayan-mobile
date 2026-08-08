
// ============================================
// FILE: lib/fatures/search/data/search_mock_data.dart
// ============================================
//
// NOTE: No unified search endpoint has been provided yet (only
// `GET /public/books?search=` exists, which is book-specific and already
// wired in the books feature). This file backs the recent-search list,
// popular hashtags, and "Fresh Articles" feed shown on the search screen
// until a real `/public/search` (or similar) endpoint exists. Replace this
// with a real datasource/cubit at that point — the screen only depends on
// `CornerArticleModel`, which is already the shared article-card shape used
// elsewhere in the app.

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';

List<String> mockRecentSearches() => [
      'Lorem',
      'Lorem Lorem 8909',
      'Lorem 7865',
      'MHMOUD',
      'Artificial',
    ];

List<String> mockPopularHashtags() => [
      '#Artificial',
      '#العقيدة الاسلامية',
      '#2026',
      '#2024',
      '#2024Collections',
      '#happyweekend book 2024',
    ];

List<CornerArticleModel> mockFreshArticles() {
  const images = [
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac44aa1e_book3.jpg',
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac46d087_book1.jpg',
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac483faf_book2.jpg',
  ];
  final now = DateTime(2026, 5, 6);
  return List.generate(images.length, (i) {
    return CornerArticleModel(
      id: 'search-article-${i + 1}',
      title: 'Adobe abandons \$20 billion acquisition of Figma',
      author: 'Dr. Ahmad Hassan',
      issueNumber: 908,
      price: 35.09,
      image: images[i],
      publishedAt: now,
      rate: 4.5,
      isFavorite: false,
    );
  });
}
