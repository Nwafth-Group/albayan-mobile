
// ============================================
// FILE: lib/fatures/offers/screens/widgets/offer_type_tabs.dart
// ============================================

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

class OfferTypeTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const OfferTypeTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: InkWell(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeMedium,
                          fontWeight:
                              i == selectedIndex ? FontWeight.bold : FontWeight.w400,
                          color: i == selectedIndex
                              ? AppColors.textPrimary
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 2.5,
                        width: 28,
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
          ],
        ),
      ),
    );
  }
}
