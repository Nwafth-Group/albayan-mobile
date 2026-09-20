
// ============================================
// FILE: lib/fatures/search/data/advanced_search_mock_data.dart
// ============================================
//
// NOTE: `GET /public/search/filters` (writers/categories/corners/etc.) has
// not been wired up yet — this screen is UI-only for now. Once the endpoint
// is integrated, replace these static lists with a datasource/cubit that
// loads the same shape.

import 'package:albayan/fatures/authors/data/models/book_model.dart';
import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';

List<String> mockWriters() => [
      'Dr. Ahmad Hassan',
      'Dr. Mahmoud Darwish',
      'Dr. Layla Ahmed',
      'Dr. Sara Youssef',
      'Dr. Omar Khalil',
    ];

List<String> mockCategories() => [
      'Literature',
      'Poetry',
      'History',
      'Religion',
      'Philosophy',
    ];

List<String> mockCorners() => [
      'Editorial',
      'Interviews',
      'Reviews',
      'Opinion',
    ];

List<String> mockKeywordChips() => [
      'Articles',
      '#العقيدة الاسلامية',
      '#2026',
      '#2024',
      '#2024Collections',
      '#happyweekend book 2024',
    ];

List<BookModel> mockSearchResultBooks() {
  const covers = [
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac43562e_book1.jpg',
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac440a79_book2.jpg',
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac44aa1e_book3.jpg',
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac46d087_book1.jpg',
  ];
  return List.generate(covers.length, (i) {
    final hasDiscount = i == 2;
    return BookModel(
      id: 'search-book-${i + 1}',
      bookId: 'search-book-${i + 1}',
      name: 'Dark woods, 0904',
      language: 'ar',
      image: covers[i],
      author: 'Dr. Ahmad Hassan',
      price: hasDiscount ? 340 : 35.09,
      finalPrice: hasDiscount ? 300 : null,
      rate: 5,
      rateCount: 12,
      isFavorite: false,
    );
  });
}

List<CornerArticleModel> mockSearchResultArticles() {
  const covers = [
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac44aa1e_book3.jpg',
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac46d087_book1.jpg',
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac483faf_book2.jpg',
  ];
  final now = DateTime(2026, 5, 6);
  return List.generate(covers.length, (i) {
    return CornerArticleModel(
      id: 'search-result-article-${i + 1}',
      title: 'Adobe abandons \$20 billion acquisition of Figma',
      author: 'Dr. Ahmad Hassan',
      issueNumber: 908,
      price: 35.09,
      image: covers[i],
      publishedAt: now,
      rate: 4.5,
      isFavorite: false,
    );
  });
}
