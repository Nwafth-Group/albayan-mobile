
// ============================================
// FILE: lib/fatures/search/screens/search_screen.dart
// ============================================

import 'package:albayan/fatures/articles/screens/article_screen.dart';
import 'package:albayan/fatures/corners/screens/widgets/corner_article_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/search_remote_data_source.dart';
import '../data/models/search_initial_model.dart';
import '../data/models/advanced_search_filter.dart';
import 'advanced_search_results_screen.dart';
import 'advanced_search_screen.dart';
import 'cubit/search_initial_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = SearchRemoteDataSourceImpl(ApiService());
        return SearchInitialCubit(dataSource)..load();
      },
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _searchController = TextEditingController();

  String? _selectedKeyword;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Runs the search for [query] and refreshes the recent-search list when
  /// the user comes back from the results.
  Future<void> _submit(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.text = q;
      _selectedKeyword = q;
    });
    final cubit = context.read<SearchInitialCubit>();
    await AppNavigator.push(
      AdvancedSearchResultsScreen(filter: AdvancedSearchFilter(query: q)),
    );
    if (!mounted) return;
    setState(() => _selectedKeyword = null);
    cubit.load();
  }

  void _clear() {
    _searchController.clear();
    setState(() => _selectedKeyword = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<SearchInitialCubit>().load(),
          child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMedium,
            AppDimensions.paddingSmall,
            AppDimensions.paddingMedium,
            AppDimensions.paddingLarge,
          ),
          children: [
            const SizedBox(height: 10,),
            _searchField(),
            const SizedBox(height: AppDimensions.paddingMedium),
            _advancedSearchButton(),
            BlocBuilder<SearchInitialCubit, SearchInitialState>(
              builder: (context, state) {
                switch (state.status) {
                  case SearchInitialStatus.initial:
                  case SearchInitialStatus.loading:
                    return const Padding(
                      padding:
                          EdgeInsets.only(top: AppDimensions.paddingXLarge),
                      child: LoadingIndicator(),
                    );

                  case SearchInitialStatus.failure:
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: AppDimensions.paddingLarge),
                      child: EmptyStateWidget(
                        image: AppImages.noData,
                        message: AppStrings.somethingWentWrong.tr(),
                        message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                        actionText: AppStrings.retry.tr(),
                        onAction: () =>
                            context.read<SearchInitialCubit>().load(),
                      ),
                    );

                  case SearchInitialStatus.success:
                    return _content(state.data);
                }
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _content(SearchInitialModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.recentSearches.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingLarge),
          _sectionTitle(AppStrings.recentSearch.tr()),
          const SizedBox(height: AppDimensions.paddingSmall),
          for (final recent in data.recentSearches)
            _RecentSearchRow(
              text: recent.query,
              onTap: () => _submit(recent.query),
              onRemove: () => context
                  .read<SearchInitialCubit>()
                  .removeRecentSearch(recent.id),
            ),
        ],
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(AppStrings.popularHashtag.tr()),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: [
            for (final keyword in data.trendingKeywords)
              _HashtagChip(
                label: keyword.name,
                selected: keyword.name == _selectedKeyword,
                onTap: () => _submit(keyword.name),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(AppStrings.freshArticles.tr()),
        const SizedBox(height: AppDimensions.paddingSmall),
        if (data.discoveryArticles.isEmpty)
          EmptyStateWidget(
            image: AppImages.noData,
            message: AppStrings.noArticles.tr(),
          )
        else
          for (final article in data.discoveryArticles)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.paddingSmall,
              ),
              child: CornerArticleCard(
                article: article,
                onTap: () => AppNavigator.push(
                  ArticleScreen(articleId: article.id),
                ),
                onFavoriteTap: () {
                  // TODO: wire favorite toggle once a favorite endpoint
                  // for search results is available.
                },
                onCartTap: () {
                  // TODO: add to cart.
                },
              ),
            ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _submit,
        onChanged: (_) => setState(() {}),
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
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                InkWell(
                  onTap: _clear,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close,
                        size: 18, color: AppColors.textLight),
                  ),
                ),
              InkWell(
                onTap: () => _submit(_searchController.text),
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(13),
                  child: Icon(Icons.search, color: AppColors.primary),
                ),
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  Widget _advancedSearchButton() {
    return InkWell(
      onTap: () => AppNavigator.push(
        AdvancedSearchScreen(initialQuery: _searchController.text),
      ),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageAsset(AppImages.searchStatus, width: 18, height: 18),
            const SizedBox(width: 8),
            Text(
              AppStrings.advancedSearch.tr(),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: AppDimensions.fontSizeLarge,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );
}

class _RecentSearchRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchRow({
    required this.text,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HashtagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HashtagChip({
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
