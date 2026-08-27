
// ============================================
// FILE: lib/fatures/library/data/library_mock_data.dart
// ============================================
//
// Placeholder data source — see the note in `library_section_model.dart`.

import '../../../utils/constants.dart';
import 'models/library_article_model.dart';
import 'models/library_book_model.dart';
import 'models/library_issue_model.dart';
import 'models/library_section_model.dart';

const _darwishCover =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac43562e_book1.jpg';
const _book2Cover =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac440a79_book2.jpg';

List<LibrarySectionModel> mockLibrarySections() => const [
      LibrarySectionModel(
        type: LibrarySectionType.books,
        titleKey: AppStrings.libraryBooks,
        countKey: AppStrings.libraryBooksCount,
        count: 20,
      ),
      LibrarySectionModel(
        type: LibrarySectionType.documents,
        titleKey: AppStrings.libraryMyDocuments,
        countKey: AppStrings.libraryDocumentsCount,
        count: 0,
      ),
      LibrarySectionModel(
        type: LibrarySectionType.magazine,
        titleKey: AppStrings.libraryAlbayanMagazine,
        countKey: AppStrings.libraryItemsCount,
        count: 15,
      ),
    ];

List<LibraryBookModel> mockLibraryBooks() => [
      const LibraryBookModel(
        id: 'lib-book-1',
        title: 'Dark woods, 0904',
        author: 'Dr. Ahmad Hassan',
        cover: null,
        progress: 0.04,
      ),
      LibraryBookModel(
        id: 'lib-book-2',
        title: 'Dark woods, 0904',
        author: 'Dr. Ahmad Hassan',
        cover: _darwishCover,
        progress: 1,
      ),
    ];

List<LibraryIssueModel> mockLibraryIssues() => [
      LibraryIssueModel(
        id: 'lib-issue-1',
        title: 'Dark woods, 0904',
        cover: _darwishCover,
        date: DateTime(2026, 5, 3),
      ),
      LibraryIssueModel(
        id: 'lib-issue-2',
        title: 'Dark woods, 0904',
        cover: _book2Cover,
        date: DateTime(2026, 5, 3),
      ),
    ];

List<LibraryArticleModel> mockLibraryArticles() => [
      LibraryArticleModel(
        id: 'lib-article-1',
        subtitle: 'Lorem lorem , 0908',
        title: 'Adobe abandons \$20 billion acquisition of Figma',
        author: 'Dr. Ahmad Hassan',
        image: _darwishCover,
        rate: 4.5,
        date: DateTime(2026, 5, 6),
      ),
      LibraryArticleModel(
        id: 'lib-article-2',
        subtitle: 'Lorem lorem , 0908',
        title: 'Adobe abandons \$20 billion acquisition of Figma',
        author: 'Dr. Ahmad Hassan',
        image: _book2Cover,
        rate: 4.5,
        date: DateTime(2026, 5, 6),
      ),
      LibraryArticleModel(
        id: 'lib-article-3',
        subtitle: 'Lorem lorem , 0908',
        title: 'Adobe abandons \$20 billion acquisition of Figma',
        author: 'Dr. Ahmad Hassan',
        image: null,
        rate: 4.5,
        date: DateTime(2026, 5, 6),
      ),
    ];

/// Starts empty to match the "0 Documents" count shown on the library home.
List<LibraryBookModel> mockLibraryDocuments() => [];
