
// ============================================
// FILE: lib/fatures/articles/screens/widgets/review_card.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../../data/models/comment_model.dart';
import 'star_row.dart';

class ReviewCard extends StatelessWidget {
  final CommentModel comment;
  const ReviewCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage:
                (comment.userImage != null && comment.userImage!.isNotEmpty)
                    ? NetworkImage(comment.userImage!)
                    : null,
                child: (comment.userImage == null || comment.userImage!.isEmpty)
                    ? const Icon(Icons.person,
                    size: 18, color: AppColors.textLight)
                    : null,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Text(
                  comment.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StarRow(rating: comment.rating, size: 13),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            comment.commentText,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (comment.submittedDate != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('MMM d, yyyy').format(comment.submittedDate!),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeSmall,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}