
// ============================================
// FILE: lib/fatures/authors/screens/widgets/books_tab.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../data/models/book_model.dart';
import 'book_card.dart';

class BooksTab extends StatelessWidget {
  final List<BookModel> items;
  final bool loadingMore;
  final VoidCallback onLoadMore;
  final void Function(BookModel) onItemTap;

  const BooksTab({
    super.key,
    required this.items,
    required this.loadingMore,
    required this.onLoadMore,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        image: AppImages.noData,
        message: AppStrings.noBooks.tr(),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
        ),
        children: [
          for (final b in items)
            BookCard(book: b, onTap: () => onItemTap(b)),
          if (loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}