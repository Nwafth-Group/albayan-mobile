// ============================================
// FILE: lib/fatures/corners/screens/widgets/filter_bottom_sheet.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_icon.dart';

enum FilterAction { apply, reset }

/// Result returned from the filter sheet (mirrors the issues sheet).
class CornerFilterResult {
  final FilterAction action;
  final DateTime? startDate;
  final DateTime? endDate;

  const CornerFilterResult.apply(this.startDate, this.endDate)
      : action = FilterAction.apply;
  const CornerFilterResult.reset()
      : action = FilterAction.reset,
        startDate = null,
        endDate = null;
}

/// Shows the date-range filter. Returns a [CornerFilterResult] for apply/reset,
/// or `null` if dismissed without choosing.
Future<CornerFilterResult?> showCornerFilterSheet(
    BuildContext context, {
      DateTime? startDate,
      DateTime? endDate,
    }) {
  return showModalBottomSheet<CornerFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterBottomSheet(
      initialStart: startDate,
      initialEnd: endDate,
    ),
  );
}

class _FilterBottomSheet extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  const _FilterBottomSheet({this.initialStart, this.initialEnd});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initialStart;
    _to = widget.initialEnd;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? _from : _to) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to != null && _to!.isBefore(picked)) _to = picked;
      } else {
        _to = picked;
        if (_from != null && _from!.isAfter(picked)) _from = picked;
      }
    });
  }

  void _reset() =>
      Navigator.of(context).pop(const CornerFilterResult.reset());

  void _apply() =>
      Navigator.of(context).pop(CornerFilterResult.apply(_from, _to));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingLarge,
        right: AppDimensions.paddingLarge,
        top: AppDimensions.paddingMedium,
        bottom:
        MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingLarge,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            AppStrings.filterBy.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            AppStrings.date.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: AppStrings.from.tr(),
                  date: _from,
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _DateField(
                  label: AppStrings.to.tr(),
                  date: _to,
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: AppDimensions.paddingLarge),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: AppStrings.reset.tr(),
                  isOutlined: true,
                  icon: Icons.refresh,
                  textColor: AppColors.primary,
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: CustomButton(
                  text: AppStrings.applyFilter.tr(),
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? 'dd/MM/yyyy'
        : DateFormat('dd/MM/yyyy', 'en').format(date!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      color: date == null
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                ImageAsset(AppImages.calendar, width: 18, height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}