// ============================================
// FILE: lib/fatures/corners/screens/widgets/corner_header.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/corner_model.dart';

/// The corner's hero card: photo with its name and header text in white,
/// and the article count in maroon where the photo fades into the page.
class CornerHeader extends StatelessWidget {
  final CornerModel corner;
  const CornerHeader({super.key, required this.corner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 1.68,
          child: Stack(
            children: [
              Positioned.fill(child: _CoverImage(url: corner.image)),
              // Darkens the middle so the white text stays legible.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.2),
                      ],
                      stops: const [0.25, 0.7, 1],
                    ),
                  ),
                ),
              ),
              // Fades the bottom edge into the page background.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0),
                        AppColors.background,
                      ],
                      stops: const [0.72, 1],
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: AppDimensions.paddingMedium,
                end: AppDimensions.paddingMedium,
                bottom: AppDimensions.paddingMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      corner.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppDimensions.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (corner.header != null &&
                        corner.header!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        corner.header!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.articlesCountLabel.tr(
                        namedArgs: {'count': corner.articlesCount.toString()},
                      ),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: AppDimensions.fontSizeLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  const _CoverImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
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
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.textLight, size: 40),
      ),
    );
  }
}
