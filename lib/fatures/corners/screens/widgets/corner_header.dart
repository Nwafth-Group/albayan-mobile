// ============================================
// FILE: lib/fatures/corners/screens/widgets/corner_header.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/corner_model.dart';

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
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            children: [
              Positioned.fill(child: _CoverImage(url: corner.image)),
              // Dark gradient for text legibility.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppDimensions.paddingMedium,
                right: AppDimensions.paddingMedium,
                bottom: AppDimensions.paddingMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      corner.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppDimensions.fontSizeXLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (corner.header != null &&
                        corner.header!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        corner.header!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppDimensions.fontSizeMedium,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.articlesCountLabel.tr(
                        namedArgs: {'count': corner.articlesCount.toString()},
                      ),
                      style: const TextStyle(
                        color: AppColors.accentLight,
                        fontSize: AppDimensions.fontSizeLarge,
                        fontWeight: FontWeight.w600,
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
        child: Icon(Icons.image_outlined,
            color: AppColors.textLight, size: 40),
      ),
    );
  }
}