// ============================================
// FILE: lib/fatures/library/screens/widgets/library_tabs.dart
// ============================================

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// Segmented tab bar sitting in a white rounded card, with the selected
/// label underlined in the primary colour. Unlike `OfferTypeTabs` the tabs
/// share the width evenly instead of scrolling horizontally.
class LibraryTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const LibraryTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeMedium,
                          fontWeight: i == selectedIndex
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: i == selectedIndex
                              ? AppColors.textPrimary
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2.5,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: i == selectedIndex
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
