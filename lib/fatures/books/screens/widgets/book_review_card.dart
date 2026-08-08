
// ============================================
// FILE: lib/fatures/books/screens/widgets/book_review_card.dart
// ============================================

import 'package:albayan/fatures/articles/screens/widgets/star_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../../../articles/data/models/comment_model.dart';

/// A single review, styled like [ReviewCard] in the articles feature but
/// with a "Do you find it helpful?" row (thumbs up/down). The API doesn't
/// expose a helpful-vote endpoint yet, so the toggle is purely local/visual.
class BookReviewCard extends StatefulWidget {
  final CommentModel comment;
  const BookReviewCard({super.key, required this.comment});

  @override
  State<BookReviewCard> createState() => _BookReviewCardState();
}

class _BookReviewCardState extends State<BookReviewCard> {
  bool? _helpful; // null = unanswered, true = up, false = down

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
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
          const SizedBox(height: AppDimensions.paddingSmall),
          Row(
            children: [
              Text(
                AppStrings.doYouFindHelpful.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeSmall,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 6),
              _HelpfulButton(
                icon: Icons.thumb_up_alt_outlined,
                selected: _helpful == true,
                onTap: () => setState(
                  () => _helpful = _helpful == true ? null : true,
                ),
              ),
              _HelpfulButton(
                icon: Icons.thumb_down_alt_outlined,
                selected: _helpful == false,
                onTap: () => setState(
                  () => _helpful = _helpful == false ? null : false,
                ),
              ),
              const Spacer(),
              if (comment.submittedDate != null)
                Text(
                  DateFormat('MMM d, yyyy').format(comment.submittedDate!),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpfulButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _HelpfulButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 16,
          color: selected ? AppColors.primary : AppColors.textLight,
        ),
      ),
    );
  }
}
