
// ============================================
// FILE: lib/fatures/authors/screens/widgets/author_list_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/author_list_model.dart';

class AuthorListCard extends StatelessWidget {
  final AuthorListModel author;
  final VoidCallback? onTap;

  const AuthorListCard({super.key, required this.author, this.onTap});

  String get _typeLabel {
    switch (author.type) {
      case 'books':
        return AppStrings.authorTypeAuthor.tr();
      case 'articles':
        return AppStrings.authorTypeWriter.tr();
      default:
        return AppStrings.authorTypeAuthor.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: SizedBox(
                width: double.infinity,
                child: _AuthorAvatar(url: author.image),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            author.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _typeLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.booksCountLabel
                .tr(namedArgs: {'count': '${author.booksCount}'}),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String? url;
  const _AuthorAvatar({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.accentPale,
      child: const Center(
        child: Icon(Icons.person, color: AppColors.primary, size: 48),
      ),
    );
  }
}
