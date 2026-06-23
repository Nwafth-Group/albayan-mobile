// ============================================
// FILE: lib/fatures/issues/screens/widgets/issues_search_bar.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/custom_icon.dart';

class IssuesSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool filterActive;
  final TextEditingController? controller;

  const IssuesSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    this.filterActive = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              // Search is by issue number → numeric input only.
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: AppStrings.searchHint.tr(),
                hintStyle: const TextStyle(color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(13),
                  child: ImageAsset(AppImages.search, width: 22, height: 22),
                ),
                suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: ImageAsset(AppImages.filter, width: 22, height: 22),
              ),
              // Active date-filter indicator dot
              if (filterActive)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
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