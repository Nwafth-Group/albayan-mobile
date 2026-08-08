
// ============================================
// FILE: lib/fatures/books/screens/widgets/about_book_tab.dart
// ============================================

import 'package:albayan/fatures/authors/screens/author_screen.dart';
import 'package:albayan/fatures/publishers/screens/publisher_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/book_detail_model.dart';
import 'author_promo_card.dart';

class AboutBookTab extends StatelessWidget {
  final BookDetailModel book;

  const AboutBookTab({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final author = book.author;
    final publisher = book.publisher;
    final description = book.version.description?.trim();
    final explanation = book.version.explanation?.trim();
    final hasOverview =
        (description != null && description.isNotEmpty) ||
            (explanation != null && explanation.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingLarge,
      ),
      children: [
        // Author
        if (author != null) ...[
          _sectionTitle(AppStrings.author.tr()),
          const SizedBox(height: AppDimensions.paddingMedium),
          _PersonRow(
            name: author.displayName,
            image: author.image,
            onVisit: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AuthorScreen(authorId: author.id),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Publisher
        if (publisher != null) ...[
          _sectionTitle(AppStrings.publisher.tr()),
          const SizedBox(height: AppDimensions.paddingMedium),
          _PersonRow(
            name: publisher.name,
            image: publisher.image,
            onVisit: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PublisherScreen(publisherId: publisher.id),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Category
        if (book.categories.isNotEmpty) ...[
          _sectionTitle(AppStrings.category.tr()),
          const SizedBox(height: AppDimensions.paddingMedium),
          _ChipsWrap(labels: book.categories.map((c) => c.name).toList()),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Keywords
        if (book.keywords.isNotEmpty) ...[
          _sectionTitle(AppStrings.keywords.tr()),
          const SizedBox(height: AppDimensions.paddingMedium),
          _ChipsWrap(labels: book.keywords.map((k) => k.name).toList()),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Overview
        if (hasOverview) ...[
          _sectionTitle(AppStrings.overviewOfBook.tr()),
          const SizedBox(height: AppDimensions.paddingSmall),
          if (description != null && description.isNotEmpty)
            Text(description, style: _bodyStyle),
          if (description != null &&
              description.isNotEmpty &&
              explanation != null &&
              explanation.isNotEmpty)
            const SizedBox(height: AppDimensions.paddingMedium),
          if (explanation != null && explanation.isNotEmpty)
            Text(explanation, style: _bodyStyle),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Discover the author promo
        if (author != null) ...[
          AuthorPromoCard(
            bookCover: book.image,
            authorImage: author.image,
            onBuyNow: () {
              // TODO: wire to purchase flow.
            },
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Book images
        if (book.version.media.isNotEmpty) ...[
          _sectionTitle(AppStrings.bookImages.tr()),
          const SizedBox(height: AppDimensions.paddingMedium),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: book.version.media.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: AppDimensions.paddingSmall),
              itemBuilder: (context, i) {
                final url = book.version.media[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  child: Image.network(
                    url,
                    width: 90,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 120,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.textLight),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: AppDimensions.fontSizeLarge,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );

  static const _bodyStyle = TextStyle(
    fontSize: AppDimensions.fontSizeMedium,
    color: AppColors.textSecondary,
    height: 1.6,
  );
}

class _PersonRow extends StatelessWidget {
  final String name;
  final String? image;
  final VoidCallback onVisit;

  const _PersonRow({
    required this.name,
    required this.image,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.surfaceVariant,
          backgroundImage: (image != null && image!.isNotEmpty)
              ? NetworkImage(image!)
              : null,
          child: (image == null || image!.isEmpty)
              ? const Icon(Icons.person, color: AppColors.textLight)
              : null,
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onVisit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppStrings.visit.tr(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: AppDimensions.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipsWrap extends StatelessWidget {
  final List<String> labels;
  const _ChipsWrap({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingSmall,
      runSpacing: AppDimensions.paddingSmall,
      children: [
        for (var i = 0; i < labels.length; i++)
          _KeywordChip(label: labels[i], highlighted: i == 0),
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  const _KeywordChip({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          color: highlighted ? AppColors.primary : AppColors.textSecondary,
          fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
