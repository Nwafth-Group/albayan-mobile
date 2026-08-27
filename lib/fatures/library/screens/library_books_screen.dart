
// ============================================
// FILE: lib/fatures/library/screens/library_books_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/library_mock_data.dart';
import '../data/models/library_book_model.dart';
import 'widgets/library_book_card.dart';

class LibraryBooksScreen extends StatefulWidget {
  const LibraryBooksScreen({super.key});

  @override
  State<LibraryBooksScreen> createState() => _LibraryBooksScreenState();
}

class _LibraryBooksScreenState extends State<LibraryBooksScreen> {
  late final List<LibraryBookModel> _books = mockLibraryBooks();

  void _delete(LibraryBookModel book) {
    setState(() => _books.removeWhere((b) => b.id == book.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryBooks.tr()),
      body: SafeArea(
        child: _books.isEmpty
            ? EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.noBooks.tr(),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.paddingMedium,
                  mainAxisSpacing: AppDimensions.paddingMedium,
                  childAspectRatio: 0.54,
                ),
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return LibraryBookCard(
                    book: book,
                    onDelete: () => _delete(book),
                  );
                },
              ),
      ),
    );
  }
}
