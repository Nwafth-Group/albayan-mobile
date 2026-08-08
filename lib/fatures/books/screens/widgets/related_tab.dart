
// ============================================
// FILE: lib/fatures/books/screens/widgets/related_tab.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../authors/data/models/book_model.dart';
import 'book_grid_card.dart';

class RelatedTab extends StatelessWidget {
  final List<BookModel> items;
  final bool loadingMore;
  final VoidCallback onLoadMore;
  final void Function(BookModel) onItemTap;

  const RelatedTab({
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
        message: AppStrings.noRelatedBooks.tr(),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingMedium,
          AppDimensions.paddingMedium,
          AppDimensions.paddingMedium,
          AppDimensions.paddingLarge,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.paddingMedium,
          crossAxisSpacing: AppDimensions.paddingMedium,
          childAspectRatio: 0.58,
        ),
        itemCount: items.length + (loadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          }
          final book = items[index];
          return BookGridCard(
            book: book,
            onTap: () => onItemTap(book),
            onCartTap: () {
              // TODO: add to cart.
            },
          );
        },
      ),
    );
  }
}
