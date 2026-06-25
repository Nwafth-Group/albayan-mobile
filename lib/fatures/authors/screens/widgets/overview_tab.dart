
// ============================================
// FILE: lib/fatures/authors/screens/widgets/overview_tab.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/author_details_model.dart';

class OverviewTab extends StatelessWidget {
  final AuthorDetailsModel author;
  final VoidCallback? onReadNow;
  final void Function(String url)? onOpenSocial;

  const OverviewTab({
    super.key,
    required this.author,
    this.onReadNow,
    this.onOpenSocial,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingLarge,
      ),
      children: [
        // Promo card
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.exploreLatestBooks.tr(),
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    GestureDetector(
                      onTap: onReadNow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppStrings.readNow.tr(),
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
              if (author.image != null && author.image!.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.paddingSmall),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  child: Image.network(
                    author.image!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Biography
        if (author.biography != null &&
            author.biography!.trim().isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            author.biography!,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],

        // Social links
        if (author.socialLinks.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingLarge),
          Row(
            children: [
              for (final entry in author.socialLinks.entries)
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimensions.paddingMedium,
                  ),
                  child: _SocialButton(
                    platform: entry.key,
                    onTap: () => onOpenSocial?.call(entry.value),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String platform;
  final VoidCallback? onTap;
  const _SocialButton({required this.platform, this.onTap});

  IconData get _icon {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
      case 'x':
        return Icons.alternate_email;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'linkedin':
        return Icons.work_outline;
      case 'youtube':
        return Icons.play_circle_outline;
      default:
        return Icons.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(_icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}