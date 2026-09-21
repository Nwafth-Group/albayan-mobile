
// ============================================
// FILE: lib/fatures/search/screens/advanced_search_results_screen.dart
// ============================================
//
// Results of `GET /public/search` for the filter chosen on the Advanced
// Search screen, split into Articles / Books / Issues tabs. Each tab has its
// own paginated cubit and sends `content_types[]=<tab>`.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../articles/screens/article_screen.dart';
import '../../articles/screens/widgets/star_row.dart';
import '../../authors/data/models/book_model.dart';
import '../../books/screens/book_screen.dart';
import '../../books/screens/widgets/book_grid_card.dart';
import '../../corners/data/models/corner_article_model.dart';
import '../../corners/screens/widgets/corner_article_card.dart';
import '../../issues/screens/issue_details_screen.dart';
import '../data/datasource/search_remote_data_source.dart';
import '../data/models/advanced_search_filter.dart';
import '../data/models/search_result_item_model.dart';
import 'cubit/search_results_cubit.dart';

class AdvancedSearchResultsScreen extends StatefulWidget {
  final AdvancedSearchFilter filter;

  const AdvancedSearchResultsScreen({super.key, required this.filter});

  @override
  State<AdvancedSearchResultsScreen> createState() =>
      _AdvancedSearchResultsScreenState();
}

class _AdvancedSearchResultsScreenState
    extends State<AdvancedSearchResultsScreen>
    with SingleTickerProviderStateMixin {
  static const _types = ['articles', 'books', 'issues'];

  late final TabController _tabController = TabController(
    length: _types.length,
    vsync: this,
    initialIndex: _initialIndex(),
  );

  late final List<SearchResultsCubit> _cubits = [
    for (final type in _types)
      SearchResultsCubit(
        SearchRemoteDataSourceImpl(ApiService()),
        widget.filter.copyWith(contentType: type),
      ),
  ];

  int _initialIndex() {
    final i = _types.indexOf(widget.filter.contentType);
    return i < 0 ? 0 : i;
  }

  final List<StreamSubscription<SearchResultsState>> _subs = [];
  SearchResultCounts _counts = SearchResultCounts.empty;
  bool _hasCounts = false;

  @override
  void initState() {
    super.initState();
    // Every response carries the counts for all three tabs.
    for (final cubit in _cubits) {
      _subs.add(cubit.stream.listen((state) {
        final counts = state.counts;
        if (counts != null && mounted) {
          setState(() {
            _counts = counts;
            _hasCounts = true;
          });
        }
      }));
    }
    _cubits[_tabController.index].load();
    _tabController.addListener(_onTabChanged);
  }

  String _tabLabel(String label, int count) =>
      _hasCounts ? '$label ($count)' : label;

  // Each tab selection re-calls `GET /public/search` with that tab's
  // `content_types[]`.
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _cubits[_tabController.index].load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    for (final sub in _subs) {
      sub.cancel();
    }
    _tabController.dispose();
    for (final cubit in _cubits) {
      cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.advancedSearch.tr()),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: TabBar(
                controller: _tabController,
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
                  Tab(
                      text: _tabLabel(
                          AppStrings.articlesTab.tr(), _counts.articles)),
                  Tab(
                      text: _tabLabel(
                          AppStrings.booksTab.tr(), _counts.books)),
                  Tab(
                      text: _tabLabel(
                          AppStrings.issuesTab.tr(), _counts.issues)),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (var i = 0; i < _types.length; i++)
                    BlocProvider.value(
                      value: _cubits[i],
                      child: _ResultsTab(type: _types[i]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsTab extends StatefulWidget {
  final String type;
  const _ResultsTab({required this.type});

  @override
  State<_ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<_ResultsTab>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<SearchResultsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<SearchResultsCubit, SearchResultsState>(
      listenWhen: (prev, curr) =>
          curr.error != null &&
          curr.error != prev.error &&
          curr.items.isNotEmpty,
      listener: (context, state) =>
          AppNavigator.showErrorSnackBar(AppStrings.somethingWentWrong.tr()),
      builder: (context, state) {
        switch (state.status) {
          case SearchResultsStatus.initial:
          case SearchResultsStatus.loading:
            return const LoadingIndicator();

          case SearchResultsStatus.failure:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
              actionText: AppStrings.retry.tr(),
              onAction: () => context.read<SearchResultsCubit>().refresh(),
            );

          case SearchResultsStatus.empty:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.noResults.tr(),
            );

          case SearchResultsStatus.success:
          case SearchResultsStatus.loadingMore:
            return Column(
              children: [
                SizedBox(
                  height: 2,
                  child: state.isRefreshing
                      ? const LinearProgressIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.surfaceVariant,
                        )
                      : null,
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        context.read<SearchResultsCubit>().refresh(),
                    child: widget.type == 'articles'
                        ? _articlesList(state)
                        : _grid(state),
                  ),
                ),
              ],
            );
        }
      },
    );
  }

  Widget _articlesList(SearchResultsState state) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) return const _LoadMoreSpinner();
        final item = state.items[index];
        return CornerArticleCard(
          article: _toCornerArticle(item),
          onTap: () => AppNavigator.push(ArticleScreen(articleId: item.id)),
          onFavoriteTap: () {},
          onCartTap: () {},
        );
      },
    );
  }

  Widget _grid(SearchResultsState state) {
    final isBooks = widget.type == 'books';
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMedium,
            AppDimensions.paddingSmall,
            AppDimensions.paddingMedium,
            0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppDimensions.paddingMedium,
              crossAxisSpacing: AppDimensions.paddingMedium,
              childAspectRatio: isBooks ? 0.58 : 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = state.items[index];
                if (isBooks) {
                  return BookGridCard(
                    book: _toBook(item),
                    onTap: () =>
                        AppNavigator.push(BookScreen(bookId: item.id)),
                    onCartTap: () {},
                  );
                }
                return _IssueResultCard(
                  item: item,
                  onTap: () =>
                      AppNavigator.push(IssueDetailsScreen(issueId: item.id)),
                );
              },
              childCount: state.items.length,
            ),
          ),
        ),
        if (state.isLoadingMore)
          const SliverToBoxAdapter(child: _LoadMoreSpinner()),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimensions.paddingLarge),
        ),
      ],
    );
  }

  CornerArticleModel _toCornerArticle(SearchResultItemModel item) {
    return CornerArticleModel(
      id: item.id,
      title: item.title,
      author: item.authorName ?? '',
      issueNumber: item.issueNumber ?? 0,
      price: item.effectivePrice,
      image: item.image,
      publishedAt: item.publishedAt,
      rate: item.rate,
      isFavorite: item.isFavorite,
    );
  }

  BookModel _toBook(SearchResultItemModel item) {
    return BookModel(
      id: item.id,
      bookId: item.versionId ?? item.id,
      name: item.title,
      language: '',
      image: item.image,
      author: item.authorName ?? '',
      price: item.price ?? 0,
      finalPrice: item.finalPrice,
      rate: item.rate,
      rateCount: 0,
      isFavorite: item.isFavorite,
    );
  }
}

class _LoadMoreSpinner extends StatelessWidget {
  const _LoadMoreSpinner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
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
    );
  }
}

/// Grid card for an issue result: cover, title, date, price and rating.
class _IssueResultCard extends StatelessWidget {
  final SearchResultItemModel item;
  final VoidCallback? onTap;

  const _IssueResultCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = item.publishedAt == null
        ? ''
        : DateFormat('MMM d, yyyy', 'en').format(item.publishedAt!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: SizedBox(
                width: double.infinity,
                child: _Cover(url: item.image),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeSmall,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 3),
          if (item.isFree || item.effectivePrice <= 0)
            Text(
              AppStrings.free.tr(),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            )
          else
            Text(
              '${item.effectivePrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(height: 3),
          StarRow(rating: item.rate, size: 13),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 32),
      ),
    );
  }
}
