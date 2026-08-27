
// ============================================
// FILE: lib/fatures/library/screens/widgets/library_book_card.dart
// ============================================
//
// 2-column grid card shared by the Books and My Documents screens: cover
// with a delete badge, title, author, and a reading-progress bar.

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/progress_bar.dart';
import '../../data/models/library_book_model.dart';
import 'library_delete_badge.dart';

class LibraryBookCard extends StatelessWidget {
  final LibraryBookModel book;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const LibraryBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.78,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    child: _Cover(url: book.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: LibraryDeleteBadge(onTap: onDelete),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          CustomProgressBar(
            value: book.progress,
            total: 1,
            height: 4,
            backgroundColor: AppColors.surfaceVariant,
            progressColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 32),
      ),
    );
  }
}
