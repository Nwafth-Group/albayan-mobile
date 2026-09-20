
// ============================================
// FILE: lib/fatures/search/screens/advanced_search_screen.dart
// ============================================
//
// UI-only screen matching the "Advanced Search" design. Filter options
// (writers/categories/corners) are static mock lists — see
// `advanced_search_mock_data.dart`. Wire this up to
// `GET /public/search/filters` (and a real search endpoint) once available.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_icon.dart';
import '../data/advanced_search_mock_data.dart';
import 'advanced_search_results_screen.dart';

enum _SearchType { books, articles, issues }

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final List<String> _writers = mockWriters();
  final List<String> _categories = mockCategories();
  final List<String> _corners = mockCorners();
  final List<String> _keywordChips = mockKeywordChips();

  final Set<String> _selectedWriters = {};
  String? _selectedCategory;
  String? _selectedCorner;

  DateTime? _fromDate;
  DateTime? _toDate;

  _SearchType _type = _SearchType.articles;

  RangeValues _priceRange = const RangeValues(50, 100);

  final Set<String> _selectedKeywords = {'Articles'};

  String _language = 'Arabic';

  double _rating = 4;

  void _reset() {
    setState(() {
      _selectedWriters.clear();
      _selectedCategory = null;
      _selectedCorner = null;
      _fromDate = null;
      _toDate = null;
      _type = _SearchType.articles;
      _priceRange = const RangeValues(50, 100);
      _selectedKeywords
        ..clear()
        ..add('Articles');
      _language = 'Arabic';
      _rating = 4;
    });
  }

  void _viewResult() {
    AppNavigator.push(const AdvancedSearchResultsScreen());
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? _fromDate : _toDate) ?? now;
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
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _pickSingle({
    required String title,
    required List<String> options,
    required String? current,
    required ValueChanged<String> onSelected,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionListSheet(
        title: title,
        options: options,
        isSelected: (o) => o == current,
        onTap: (o) => Navigator.of(context).pop(o),
      ),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _pickMultiWriters() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MultiOptionListSheet(
        title: AppStrings.writers.tr(),
        options: _writers,
        initialSelected: _selectedWriters,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedWriters
          ..clear()
          ..addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.advancedSearch.tr()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMedium,
            0,
            AppDimensions.paddingMedium,
            AppDimensions.paddingLarge,
          ),
          children: [
            _label(AppStrings.writers.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            _DropdownField(
              hint: AppStrings.chooseWriters.tr(),
              value: _selectedWriters.isEmpty
                  ? null
                  : _selectedWriters.join(', '),
              onTap: _pickMultiWriters,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Row(
              children: [
                Expanded(child: _label(AppStrings.fromDate.tr())),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(child: _label(AppStrings.toDate.tr())),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    date: _fromDate,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: _DateField(
                    date: _toDate,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _label(AppStrings.type.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              children: [
                _OutlinePillChip(
                  label: AppStrings.booksTab.tr(),
                  selected: _type == _SearchType.books,
                  onTap: () => setState(() => _type = _SearchType.books),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                _OutlinePillChip(
                  label: AppStrings.articlesTab.tr(),
                  selected: _type == _SearchType.articles,
                  onTap: () => setState(() => _type = _SearchType.articles),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                _OutlinePillChip(
                  label: AppStrings.issuesTab.tr(),
                  selected: _type == _SearchType.issues,
                  onTap: () => setState(() => _type = _SearchType.issues),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _label(AppStrings.price.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            _PriceRangeCard(
              range: _priceRange,
              onChanged: (v) => setState(() => _priceRange = v),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _label(AppStrings.keywords.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            Wrap(
              spacing: AppDimensions.paddingSmall,
              runSpacing: AppDimensions.paddingSmall,
              children: [
                for (final chip in _keywordChips)
                  _FilledChip(
                    label: chip,
                    selected: _selectedKeywords.contains(chip),
                    onTap: () => setState(() {
                      if (_selectedKeywords.contains(chip)) {
                        _selectedKeywords.remove(chip);
                      } else {
                        _selectedKeywords.add(chip);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _label(AppStrings.category.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            _DropdownField(
              hint: AppStrings.chooseWriters.tr(),
              value: _selectedCategory,
              onTap: () => _pickSingle(
                title: AppStrings.category.tr(),
                options: _categories,
                current: _selectedCategory,
                onSelected: (v) => setState(() => _selectedCategory = v),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _label(AppStrings.cornersTitle.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            _DropdownField(
              hint: AppStrings.chooseCorner.tr(),
              value: _selectedCorner,
              onTap: () => _pickSingle(
                title: AppStrings.cornersTitle.tr(),
                options: _corners,
                current: _selectedCorner,
                onSelected: (v) => setState(() => _selectedCorner = v),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _label(AppStrings.language.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              children: [
                _OutlinePillChip(
                  label: 'Arabic',
                  selected: _language == 'Arabic',
                  onTap: () => setState(() => _language = 'Arabic'),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                _OutlinePillChip(
                  label: 'English',
                  selected: _language == 'English',
                  onTap: () => setState(() => _language = 'English'),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                _OutlinePillChip(
                  label: 'French',
                  selected: _language == 'French',
                  onTap: () => setState(() => _language = 'French'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _label(AppStrings.rating.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            _RatingStars(
              rating: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: AppDimensions.paddingXLarge),
            CustomButton(
              text: AppStrings.viewResult.tr(),
              onPressed: _viewResult,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Center(
              child: TextButton(
                onPressed: _reset,
                child: Text(
                  AppStrings.reset.tr(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? 'Choose Date'
        : '${date!.day.toString().padLeft(2, '0')}/'
            '${date!.month.toString().padLeft(2, '0')}/'
            '${date!.year}';
    return InkWell(
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
                  fontSize: AppDimensions.fontSizeSmall,
                  color:
                      date == null ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ),
            ImageAsset(AppImages.calendar, width: 16, height: 16),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                value?.isNotEmpty == true ? value! : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  color: (value?.isNotEmpty == true)
                      ? AppColors.textPrimary
                      : AppColors.textLight,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinePillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OutlinePillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.fontSizeSmall,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

class _FilledChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilledChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentPale : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.fontSizeSmall,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PriceRangeCard extends StatelessWidget {
  final RangeValues range;
  final ValueChanged<RangeValues> onChanged;

  static const double _min = 10;
  static const double _max = 1000;

  const _PriceRangeCard({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.priceRange.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Text(
                  '${range.start.round()}-${range.end.round()}',
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceVariant,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withAlpha(30),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              trackHeight: 3,
            ),
            child: RangeSlider(
              min: _min,
              max: _max,
              values: range,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('10',
                    style: TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textLight)),
                Text('500',
                    style: TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textLight)),
                Text('1000',
                    style: TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _RatingStars({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InkWell(
            onTap: () => onChanged((i + 1).toDouble()),
            customBorder: const CircleBorder(),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 28,
            ),
          ),
        );
      }),
    );
  }
}

class _OptionListSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final bool Function(String) isSelected;
  final ValueChanged<String> onTap;

  const _OptionListSheet({
    required this.title,
    required this.options,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingMedium,
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
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
            title,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          for (final option in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option),
              trailing: isSelected(option)
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => onTap(option),
            ),
        ],
      ),
    );
  }
}

class _MultiOptionListSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final Set<String> initialSelected;

  const _MultiOptionListSheet({
    required this.title,
    required this.options,
    required this.initialSelected,
  });

  @override
  State<_MultiOptionListSheet> createState() => _MultiOptionListSheetState();
}

class _MultiOptionListSheetState extends State<_MultiOptionListSheet> {
  late final Set<String> _selected = {...widget.initialSelected};

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
            widget.title,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          for (final option in widget.options)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _selected.contains(option),
              activeColor: AppColors.primary,
              title: Text(option),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) => setState(() {
                if (checked == true) {
                  _selected.add(option);
                } else {
                  _selected.remove(option);
                }
              }),
            ),
          const SizedBox(height: AppDimensions.paddingSmall),
          CustomButton(
            text: AppStrings.applyFilter.tr(),
            onPressed: () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
    );
  }
}
