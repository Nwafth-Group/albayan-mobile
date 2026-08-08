
// ============================================
// FILE: lib/fatures/authors/screens/author_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:albayan/fatures/articles/screens/article_screen.dart';
import 'package:albayan/fatures/books/screens/book_screen.dart';
import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/datasource/authors_remote_data_source.dart';
import 'cubit/author_cubit.dart';
import 'widgets/author_articles_tab.dart';
import 'widgets/books_tab.dart';
import 'widgets/overview_tab.dart';

const Color _kHeaderDark = Color(0xFF26201D);

class AuthorScreen extends StatelessWidget {
  final String authorId;
  const AuthorScreen({super.key, required this.authorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthorCubit(
        AuthorsRemoteDataSourceImpl(ApiService()),
        authorId: authorId,
      )..load(),
      child: const _AuthorView(),
    );
  }
}

class _AuthorView extends StatefulWidget {
  const _AuthorView();

  @override
  State<_AuthorView> createState() => _AuthorViewState();
}

class _AuthorViewState extends State<_AuthorView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      body: BlocBuilder<AuthorCubit, AuthorState>(
        builder: (context, state) {
          if (state.status == AuthorStatus.loading && state.author == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.status == AuthorStatus.failure && state.author == null) {
            return SafeArea(
              child: EmptyStateWidget(
                icon: Icons.wifi_off_rounded,
                message: AppStrings.somethingWentWrong.tr(),
                message2: state.error,
                actionText: AppStrings.retry.tr(),
                onAction: () => context.read<AuthorCubit>().load(),
              ),
            );
          }

          final author = state.author!;
          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              _buildHeader(context, state),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textLight,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: AppStrings.overview.tr()),
                      Tab(text: AppStrings.articlesTab.tr()),
                      Tab(text: AppStrings.booksTab.tr()),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(
                  author: author,
                  onReadNow: () => _tabController.animateTo(2),
                  onOpenSocial: (url) {/* TODO: launch url */},
                ),
                AuthorArticlesTab(
                  items: state.articles,
                  years: state.years,
                  selectedYear: state.selectedYear,
                  loadingMore: state.articlesStatus == ListStatus.loadingMore,
                  onYearSelected: (y) =>
                      context.read<AuthorCubit>().selectYear(y),
                  onLoadMore: () =>
                      context.read<AuthorCubit>().loadMoreArticles(),
                  onItemTap: (a) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleScreen(articleId: a.id),
                    ),
                  ),
                ),
                BooksTab(
                  items: state.books,
                  loadingMore: state.booksStatus == ListStatus.loadingMore,
                  onLoadMore: () =>
                      context.read<AuthorCubit>().loadMoreBooks(),
                  onItemTap: (b) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookScreen(bookId: b.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthorState state) {
    final author = state.author!;
    final subtitle = author.shortBio ?? author.nickname ?? '';
    final collections = state.collectionsCount;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 360,
      backgroundColor: _kHeaderDark,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        AppStrings.authorDetails.tr(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (author.image != null)
              Image.network(
                author.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const ColoredBox(color: _kHeaderDark),
              )
            else
              const ColoredBox(color: _kHeaderDark),
            // Gradient for legibility
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
            // Name / subtitle / collections
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingXLarge,
                  left: AppDimensions.paddingLarge,
                  right: AppDimensions.paddingLarge,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      author.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppDimensions.fontSizeXXLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: AppDimensions.fontSizeMedium,
                        ),
                      ),
                    ],
                    if (collections > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.collectionsCount.tr(
                          namedArgs: {'count': collections.toString()},
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: AppDimensions.fontSizeMedium,
                        ),
                      ),
                    ],
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

/// Pinned TabBar header on the cream sheet (rounded top corners).
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}