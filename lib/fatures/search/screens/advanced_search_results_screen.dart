
// ============================================
// FILE: lib/fatures/search/screens/advanced_search_results_screen.dart
// ============================================
//
// UI-only results screen (Books / Articles tabs) for the Advanced Search
// filters. Backed by mock data until a real search endpoint exists — see
// `advanced_search_mock_data.dart`.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../articles/screens/article_screen.dart';
import '../../books/screens/book_screen.dart';
import '../../books/screens/widgets/book_grid_card.dart';
import '../../corners/screens/widgets/corner_article_card.dart';
import '../data/advanced_search_mock_data.dart';

class AdvancedSearchResultsScreen extends StatefulWidget {
  const AdvancedSearchResultsScreen({super.key});

  @override
  State<AdvancedSearchResultsScreen> createState() =>
      _AdvancedSearchResultsScreenState();
}

class _AdvancedSearchResultsScreenState
    extends State<AdvancedSearchResultsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  final _books = mockSearchResultBooks();
  final _articles = mockSearchResultArticles();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.advancedSearch.tr(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: _ResultTabBar(controller: _tabController),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _booksGrid(),
                  _articlesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _booksGrid() {
    if (_books.isEmpty) {
      return EmptyStateWidget(
        image: AppImages.noData,
        message: AppStrings.noBooks.tr(),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingSmall,
        AppDimensions.paddingMedium,
        AppDimensions.paddingLarge,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.paddingMedium,
        crossAxisSpacing: AppDimensions.paddingMedium,
        childAspectRatio: 0.58,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return BookGridCard(
          book: book,
          onTap: () => AppNavigator.push(BookScreen(bookId: book.id)),
          onCartTap: () {},
        );
      },
    );
  }

  Widget _articlesList() {
    if (_articles.isEmpty) {
      return EmptyStateWidget(
        image: AppImages.noData,
        message: AppStrings.noArticles.tr(),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
      ),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return CornerArticleCard(
          article: article,
          onTap: () =>
              AppNavigator.push(ArticleScreen(articleId: article.id)),
          onFavoriteTap: () {},
          onCartTap: () {},
        );
      },
    );
  }
}

class _ResultTabBar extends StatelessWidget {
  final TabController controller;

  const _ResultTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: false,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textLight,
      labelStyle: const TextStyle(
        fontSize: AppDimensions.fontSizeMedium,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: AppDimensions.fontSizeMedium,
        fontWeight: FontWeight.w400,
      ),
      tabs: [
        Tab(text: AppStrings.booksTab.tr()),
        Tab(text: AppStrings.articlesTab.tr()),
      ],
    );
  }
}
