
// ============================================
// FILE: lib/fatures/authors/screens/widgets/year_filter_chips.dart
// ============================================

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

class YearFilterChips extends StatelessWidget {
  final List<int> years;
  final int? selected;
  final ValueChanged<int> onSelected;

  const YearFilterChips({
    super.key,
    required this.years,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (years.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        itemCount: years.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: AppDimensions.paddingSmall),
        itemBuilder: (_, i) {
          final year = years[i];
          final isSelected = year == selected;
          return GestureDetector(
            onTap: () => onSelected(year),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentPale : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                ),
              ),
              child: Text(
                year.toString(),
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}