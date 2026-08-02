// ============================================
// FILE: lib/fatures/articles/screens/articles_list_screen.dart
// ============================================

import 'package:albayan/fatures/articles/screens/article_screen.dart';
import 'package:albayan/fatures/corners/screens/widgets/corner_article_card.dart';
import 'package:albayan/fatures/corners/screens/widgets/corners_search_bar.dart';
import 'package:albayan/fatures/corners/screens/widgets/filter_bottom_sheet.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/articles_remote_data_source.dart';
import 'cubit/articles_list_cubit.dart';

class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final api = ApiService();
        final dataSource = ArticlesRemoteDataSourceImpl(api);
        return ArticlesListCubit(dataSource)..load();
      },
      child: const _ArticlesListView(),
    );
  }
}

class _ArticlesListView extends StatefulWidget {
  const _ArticlesListView();

  @override
  State<_ArticlesListView> createState() => _ArticlesListViewState();
}

class _ArticlesListViewState extends State<_ArticlesListView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<ArticlesListCubit>().loadMore();
    }
  }

  Future<void> _openFilter() async {
    final cubit = context.read<ArticlesListCubit>();
    final result = await showCornerFilterSheet(
      context,
      startDate: cubit.state.filter.fromDate,
      endDate: cubit.state.filter.toDate,
    );
    if (result == null) return;
    if (result.action == FilterAction.reset) {
      await cubit.resetDates();
    } else {
      await cubit.applyDates(from: result.startDate, to: result.endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.articlesTitle.tr()),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium),
              child: BlocBuilder<ArticlesListCubit, ArticlesListState>(
                buildWhen: (a, b) => a.filter.hasDates != b.filter.hasDates,
                builder: (context, state) {
                  return CornersSearchBar(
                    controller: _searchController,
                    filterActive: state.filter.hasDates,
                    onChanged: (q) =>
                        context.read<ArticlesListCubit>().search(q),
                    onFilterTap: _openFilter,
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ArticlesListCubit, ArticlesListState>(
      builder: (context, state) {
        switch (state.status) {
          case ArticlesListStatus.initial:
          case ArticlesListStatus.loading:
            return const LoadingIndicator();

          case ArticlesListStatus.failure:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
              actionText: AppStrings.retry.tr(),
              onAction: () => context.read<ArticlesListCubit>().refresh(),
            );

          case ArticlesListStatus.empty:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.noArticles.tr(),
            );

          case ArticlesListStatus.success:
          case ArticlesListStatus.loadingMore:
            return _ArticlesList(
              scrollController: _scrollController,
              state: state,
              onRefresh: () => context.read<ArticlesListCubit>().refresh(),
            );
        }
      },
    );
  }
}

class _ArticlesList extends StatelessWidget {
  final ScrollController scrollController;
  final ArticlesListState state;
  final Future<void> Function() onRefresh;

  const _ArticlesList({
    required this.scrollController,
    required this.state,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final article = state.articles[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: CornerArticleCard(
                      article: article,
                      onTap: () {
                        AppNavigator.push(
                            ArticleScreen(articleId: article.id));
                      },
                      onFavoriteTap: () => context
                          .read<ArticlesListCubit>()
                          .toggleFavorite(article.id),
                      onCartTap: () {
                        // TODO: add to cart.
                      },
                    ),
                  );
                },
                childCount: state.articles.length,
              ),
            ),
          ),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding:
                EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingMedium),
          ),
        ],
      ),
    );
  }
}
