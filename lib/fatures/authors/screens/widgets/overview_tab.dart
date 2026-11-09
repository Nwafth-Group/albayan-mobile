
// ============================================
// FILE: lib/fatures/authors/screens/widgets/overview_tab.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../utils/constants.dart';
import '../../../../utils/link_launcher.dart';
import '../../data/models/author_details_model.dart';
import 'author_placeholder.dart';

class OverviewTab extends StatelessWidget {
  final AuthorDetailsModel author;
  final VoidCallback? onReadNow;
  final VoidCallback? onShare;

  const OverviewTab({
    super.key,
    required this.author,
    this.onReadNow,
    this.onShare,
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
              const SizedBox(width: AppDimensions.paddingSmall),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: author.image != null && author.image!.isNotEmpty
                      ? Image.network(
                          author.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const AuthorPlaceholder(),
                        )
                      : const AuthorPlaceholder(),
                ),
              ),
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
          _SocialLinks(links: author.socialLinks),
        ],

        // Share
        const SizedBox(height: AppDimensions.paddingLarge),
        InkWell(
          onTap: onShare,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.ios_share, size: 18, color: AppColors.primary),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(
                  AppStrings.share.tr(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
/// The author's `social_links` (keyed by platform), each opening the
/// author's account externally. Unknown platforms get a generic link icon.
class _SocialLinks extends StatelessWidget {
  final Map<String, String> links;
  const _SocialLinks({required this.links});

  static (List<List<dynamic>>, Color) _styleOf(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
      case 'x':
        return (HugeIcons.strokeRoundedNewTwitter, Colors.black);
      case 'instagram':
        return (HugeIcons.strokeRoundedInstagram, const Color(0xFFE1306C));
      case 'linkedin':
        return (HugeIcons.strokeRoundedLinkedin01, const Color(0xFF0A66C2));
      case 'facebook':
        return (HugeIcons.strokeRoundedFacebook01, const Color(0xFF1877F2));
      case 'youtube':
        return (HugeIcons.strokeRoundedYoutube, const Color(0xFFFF0000));
      case 'tiktok':
        return (HugeIcons.strokeRoundedTiktok, Colors.black);
      case 'telegram':
        return (HugeIcons.strokeRoundedTelegram, const Color(0xFF229ED9));
      case 'snapchat':
        return (HugeIcons.strokeRoundedSnapchat, const Color(0xFFFFC107));
      case 'website':
        return (HugeIcons.strokeRoundedGlobe02, AppColors.primary);
      default:
        return (HugeIcons.strokeRoundedLink01, AppColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingSmall,
      runSpacing: AppDimensions.paddingSmall,
      children: [
        for (final entry in links.entries)
          Builder(
            builder: (_) {
              final (icon, color) = _styleOf(entry.key);
              return InkWell(
                onTap: () => LinkLauncher.openUrl(entry.value),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(icon: icon, color: color, size: 22),
                ),
              );
            },
          ),
      ],
    );
  }
}
