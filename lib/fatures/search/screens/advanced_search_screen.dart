
// ============================================
// FILE: lib/fatures/search/screens/advanced_search_screen.dart
// ============================================
//
// Advanced Search filters. Option lists come from `/public/authors`,
// `/public/categories`, `/public/corners`, `/public/languages` and
// `/public/keywords` (see `AdvancedSearchFiltersCubit`). "View Result"
// hands the chosen filter to the results screen (`GET /public/search`).

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../authors/data/datasource/authors_remote_data_source.dart';
import '../../corners/data/datasource/corners_remote_data_source.dart';
import '../../onboarding/data/language_remote_datasource.dart';
import '../data/datasource/search_filters_remote_data_source.dart';
import '../data/models/advanced_search_filter.dart';
import 'advanced_search_results_screen.dart';
import 'cubit/advanced_search_filters_cubit.dart';

enum _SearchType { books, articles, issues }

/// An id/label pair shown in the picker sheets.
class _Option {
  final String id;
  final String label;
  const _Option(this.id, this.label);
}

class AdvancedSearchScreen extends StatelessWidget {
  /// Text typed in the main search field, carried into the `q` filter.
  final String initialQuery;

  const AdvancedSearchScreen({super.key, this.initialQuery = ''});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdvancedSearchFiltersCubit(
        authorsDataSource: AuthorsRemoteDataSourceImpl(ApiService()),
        cornersDataSource: CornersRemoteDataSourceImpl(ApiService()),
        filtersDataSource: SearchFiltersRemoteDataSourceImpl(ApiService()),
        languagesDataSource: LanguageRemoteDataSource(ApiService()),
      )..load(),
      child: _AdvancedSearchView(initialQuery: initialQuery),
    );
  }
}

class _AdvancedSearchView extends StatefulWidget {
  final String initialQuery;
  const _AdvancedSearchView({required this.initialQuery});

  @override
  State<_AdvancedSearchView> createState() => _AdvancedSearchViewState();
}

class _AdvancedSearchViewState extends State<_AdvancedSearchView> {
  static const _defaultPriceRange = RangeValues(50, 100);

  final Set<String> _selectedWriterIds = {};
  String? _selectedCategoryId;
  String? _selectedCornerId;

  DateTime? _fromDate;
  DateTime? _toDate;

  _SearchType _type = _SearchType.articles;

  RangeValues _priceRange = _defaultPriceRange;

  String? _selectedKeywordId;
  String? _languageCode;

  double _rating = 4;

  void _reset() {
    setState(() {
      _selectedWriterIds.clear();
      _selectedCategoryId = null;
      _selectedCornerId = null;
      _fromDate = null;
      _toDate = null;
      _type = _SearchType.articles;
      _priceRange = _defaultPriceRange;
      _selectedKeywordId = null;
      _languageCode = null;
      _rating = 4;
    });
  }

  void _viewResult() {
    final filter = AdvancedSearchFilter(
      query: widget.initialQuery,
      authorIds: {..._selectedWriterIds},
      fromDate: _fromDate,
      toDate: _toDate,
      contentType: _type.name,
      priceFrom: _priceRange.start.roundToDouble(),
      priceTo: _priceRange.end.roundToDouble(),
      categoryId: _selectedCategoryId,
      cornerId: _selectedCornerId,
      languageCode: _languageCode,
      minRating: _rating,
      keywordId: _selectedKeywordId,
    );
    AppNavigator.push(AdvancedSearchResultsScreen(filter: filter));
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
    required List<_Option> options,
    required String? currentId,
    required ValueChanged<String> onSelected,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionListSheet(
        title: title,
        options: options,
        isSelected: (o) => o.id == currentId,
        onTap: (o) => Navigator.of(context).pop(o.id),
      ),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _pickWriters(List<_Option> options) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MultiOptionListSheet(
        title: AppStrings.writers.tr(),
        options: options,
        initialSelected: _selectedWriterIds,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedWriterIds
          ..clear()
          ..addAll(result);
      });
    }
  }

  String? _labelFor(List<_Option> options, String? id) {
    if (id == null) return null;
    for (final o in options) {
      if (o.id == id) return o.label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.advancedSearch.tr()),
      body: SafeArea(
        child: BlocBuilder<AdvancedSearchFiltersCubit,
            AdvancedSearchFiltersState>(
          builder: (context, state) {
            switch (state.status) {
              case AdvancedSearchFiltersStatus.initial:
              case AdvancedSearchFiltersStatus.loading:
                return const LoadingIndicator();

              case AdvancedSearchFiltersStatus.failure:
                return EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.somethingWentWrong.tr(),
                  message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                  actionText: AppStrings.retry.tr(),
                  onAction: () =>
                      context.read<AdvancedSearchFiltersCubit>().load(),
                );

              case AdvancedSearchFiltersStatus.success:
                return _form(context, state);
            }
          },
        ),
      ),
    );
  }

  Widget _form(BuildContext context, AdvancedSearchFiltersState state) {
    final locale = context.locale.languageCode;
    final writers =
        state.authors.map((a) => _Option(a.id, a.name)).toList();
    final categories =
        state.categories.map((c) => _Option(c.id, c.name)).toList();
    final corners = state.corners.map((c) => _Option(c.id, c.name)).toList();

    final writersValue = _selectedWriterIds.isEmpty
        ? null
        : writers
            .where((w) => _selectedWriterIds.contains(w.id))
            .map((w) => w.label)
            .join(', ');

    return ListView(
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
          value: writersValue,
          onTap: () => _pickWriters(writers),
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
              label: AppStrings.articlesTab.tr(),
              selected: _type == _SearchType.articles,
              onTap: () => setState(() => _type = _SearchType.articles),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            _OutlinePillChip(
              label: AppStrings.booksTab.tr(),
              selected: _type == _SearchType.books,
              onTap: () => setState(() => _type = _SearchType.books),
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
        if (state.keywords.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingLarge),
          _label(AppStrings.keywords.tr()),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: [
              for (final keyword in state.keywords)
                _FilledChip(
                  label: keyword.name,
                  selected: keyword.id == _selectedKeywordId,
                  onTap: () => setState(() {
                    _selectedKeywordId =
                        keyword.id == _selectedKeywordId ? null : keyword.id;
                  }),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppDimensions.paddingLarge),
        _label(AppStrings.category.tr()),
        const SizedBox(height: AppDimensions.paddingSmall),
        _DropdownField(
          hint: AppStrings.chooseCategory.tr(),
          value: _labelFor(categories, _selectedCategoryId),
          onTap: () => _pickSingle(
            title: AppStrings.category.tr(),
            options: categories,
            currentId: _selectedCategoryId,
            onSelected: (v) => setState(() => _selectedCategoryId = v),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _label(AppStrings.cornersTitle.tr()),
        const SizedBox(height: AppDimensions.paddingSmall),
        _DropdownField(
          hint: AppStrings.chooseCorner.tr(),
          value: _labelFor(corners, _selectedCornerId),
          onTap: () => _pickSingle(
            title: AppStrings.cornersTitle.tr(),
            options: corners,
            currentId: _selectedCornerId,
            onSelected: (v) => setState(() => _selectedCornerId = v),
          ),
        ),
        if (state.languages.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingLarge),
          _label(AppStrings.language.tr()),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: [
              for (final language in state.languages)
                _OutlinePillChip(
                  label: language.displayName(locale),
                  selected: language.code == _languageCode,
                  onTap: () => setState(() {
                    _languageCode =
                        language.code == _languageCode ? null : language.code;
                  }),
                ),
            ],
          ),
        ],
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
  final List<_Option> options;
  final bool Function(_Option) isSelected;
  final ValueChanged<_Option> onTap;

  const _OptionListSheet({
    required this.title,
    required this.options,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    trailing: isSelected(option)
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () => onTap(option),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiOptionListSheet extends StatefulWidget {
  final String title;
  final List<_Option> options;
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
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
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in widget.options)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _selected.contains(option.id),
                    activeColor: AppColors.primary,
                    title: Text(option.label),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selected.add(option.id);
                      } else {
                        _selected.remove(option.id);
                      }
                    }),
                  ),
              ],
            ),
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
