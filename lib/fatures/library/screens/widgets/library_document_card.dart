// ============================================
// FILE: lib/fatures/library/screens/widgets/library_document_card.dart
// ============================================
//
// 2-column grid card for "My Documents": a generic PDF placeholder (no
// cover image for uploaded files), title, file size, a reading-progress
// bar, and delete / download badges over the cover.

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/progress_bar.dart';
import '../../data/models/personal_document_model.dart';
import 'library_delete_badge.dart';

class LibraryDocumentCard extends StatelessWidget {
  final PersonalDocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onDownload;

  /// This document's delete request is in flight — shows a spinner badge
  /// instead of the trash icon so the user can't double-tap it.
  final bool isDeleting;

  const LibraryDocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
    this.onDownload,
    this.isDeleting = false,
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
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    child: const _CoverPlaceholder(),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _MiniBadge(
                    icon: Icons.download_outlined,
                    onTap: onDownload,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: isDeleting
                      ? const _MiniSpinnerBadge()
                      : LibraryDeleteBadge(onTap: onDelete),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            document.title,
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
            document.file.fileSizeFormatted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          CustomProgressBar(
            value: document.progress,
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

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.picture_as_pdf_outlined,
          color: AppColors.textLight,
          size: 32,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _MiniBadge({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: AppColors.primary),
      ),
    );
  }
}

class _MiniSpinnerBadge extends StatelessWidget {
  const _MiniSpinnerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
