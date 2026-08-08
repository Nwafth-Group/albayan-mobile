// ============================================
// FILE: lib/fatures/search/screens/search_screen.dart
// ============================================

import 'package:albayan/fatures/articles/screens/article_screen.dart';
import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import 'package:albayan/fatures/corners/screens/widgets/corner_article_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/search_mock_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  // TODO: replace with a real search datasource/cubit once a unified
  // search endpoint exists. For now this renders from mock data.
  late final List<String> _recentSearches = mockRecentSearches();
  final List<String> _hashtags = mockPopularHashtags();
  final List<CornerArticleModel> _freshArticles = mockFreshArticles();

  int _selectedHashtag = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeRecent(int index) {
    setState(() => _recentSearches.removeAt(index));
  }

  void _applyHashtag(int index) {
    setState(() {
      _selectedHashtag = index;
      _searchController.text = _hashtags[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMedium,
            AppDimensions.paddingSmall,
            AppDimensions.paddingMedium,
            AppDimensions.paddingLarge,
          ),
          children: [
            const SizedBox(height: 10,),
            _searchField(),
            if (_recentSearches.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingLarge),
              _sectionTitle(AppStrings.recentSearch.tr()),
              const SizedBox(height: AppDimensions.paddingSmall),
              for (var i = 0; i < _recentSearches.length; i++)
                _RecentSearchRow(
                  text: _recentSearches[i],
                  onTap: () => setState(
                        () => _searchController.text = _recentSearches[i],
                  ),
                  onRemove: () => _removeRecent(i),
                ),
            ],
            const SizedBox(height: AppDimensions.paddingLarge),
            _sectionTitle(AppStrings.popularHashtag.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            Wrap(
              spacing: AppDimensions.paddingSmall,
              runSpacing: AppDimensions.paddingSmall,
              children: [
                for (var i = 0; i < _hashtags.length; i++)
                  _HashtagChip(
                    label: _hashtags[i],
                    selected: i == _selectedHashtag,
                    onTap: () => _applyHashtag(i),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _sectionTitle(AppStrings.freshArticles.tr()),
            const SizedBox(height: AppDimensions.paddingSmall),
            if (_freshArticles.isEmpty)
              EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.noArticles.tr(),
              )
            else
              for (final article in _freshArticles)
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
                      // TODO: wire favorite toggle once real search results
                      // carry stable, real article ids.
                    },
                    onCartTap: () {
                      // TODO: add to cart.
                    },
                  ),
                ),
          ],
        ),
      ),
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
        // TODO: wire to a search API once the endpoint is available.
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
          suffixIcon: const Padding(
            padding: EdgeInsets.all(13),
            child: Icon(Icons.search, color: AppColors.primary),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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