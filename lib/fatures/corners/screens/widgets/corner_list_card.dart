
// ============================================
// FILE: lib/fatures/corners/screens/widgets/corner_list_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/corner_model.dart';

class CornerListCard extends StatelessWidget {
  final CornerModel corner;
  final VoidCallback? onTap;

  const CornerListCard({super.key, required this.corner, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image fills the leftover vertical space so the card never overflows.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: SizedBox(
                width: double.infinity,
                child: _CornerImage(url: corner.image),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            corner.name,
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
            AppStrings.articlesCountLabel
                .tr(namedArgs: {'count': '${corner.articlesCount}'}),
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

class _CornerImage extends StatelessWidget {
  final String? url;
  const _CornerImage({this.url});

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
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.grid_view_rounded,
            color: AppColors.textLight, size: 32),
      ),
    );
  }
}
