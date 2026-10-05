// ============================================
// FILE: lib/widgets/detail_tabs.dart
// ============================================
//
// Text tabs used on the issue and article details pages: the selected tab
// is dark with a short maroon underline, the rest are light grey.

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class DetailTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Gap between two tab labels.
  final double spacing;

  const DetailTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.spacing = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: i == labels.length - 1 ? 0 : spacing,
              ),
              child: _DetailTab(
                label: labels[i],
                selected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DetailTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // IntrinsicWidth sizes the column to the label, so the underline can
      // be capped at 80 without widening a shorter label's tab.
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.textPrimary : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Container(
                  width: double.infinity,
                  height: 2,
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
