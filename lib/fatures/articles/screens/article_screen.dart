// ============================================
// FILE: lib/fatures/articles/screens/article_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/detail_hero.dart';
import '../../../widgets/detail_tabs.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/web_view_screen.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../cart/utils/add_to_cart_mixin.dart';
import '../data/datasource/articles_remote_data_source.dart';
import 'cubit/article_cubit.dart';
import 'widgets/about_article_tab.dart';
import 'widgets/article_info_bar.dart';
import 'widgets/rate_experience_sheet.dart';
import 'widgets/reviews_tab.dart';
import 'widgets/similar_tab.dart';

class ArticleScreen extends StatelessWidget {
  final String articleId;
  const ArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticleCubit(
        ArticlesRemoteDataSourceImpl(ApiService()),
        articleId: articleId,
      )..load(),
      child: const _ArticleView(),
    );
  }
}

class _ArticleView extends StatefulWidget {
  const _ArticleView();

  @override
  State<_ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<_ArticleView>
    with SingleTickerProviderStateMixin, AddToCartStateMixin {
  /// Height of the cream sheet's rounded top that overlaps the hero.
  static const _sheetRadius = 28.0;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openRating() async {
    final cubit = context.read<ArticleCubit>();
    final result = await showRateExperienceSheet(context);
    if (result == null) return;
    final ok = await cubit.submitRating(
      rating: result.rating,
      comment: result.comment,
    );
    if (!mounted) return;
    if (ok) {
      Helpers.showSuccess(context, AppStrings.feedbackSent.tr());
    } else {
      Helpers.showError(AppStrings.somethingWentWrong.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      body: BlocBuilder<ArticleCubit, ArticleState>(
        builder: (context, state) {
          if (state.status == ArticleStatus.loading && state.article == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.status == ArticleStatus.failure && state.article == null) {
            return SafeArea(
              child: EmptyStateWidget(
                icon: Icons.wifi_off_rounded,
                message: AppStrings.somethingWentWrong.tr(),
                message2: state.error,
                actionText: AppStrings.retry.tr(),
                onAction: () => context.read<ArticleCubit>().load(),
              ),
            );
          }

          final article = state.article!;
          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              _buildHeader(context, state),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.paddingxSmall,
                    bottom: AppDimensions.paddingLarge,
                  ),
                  child: ArticleInfoBar(article: article),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabsDelegate(
                  selectedIndex: _tabController.index,
                  child: DetailTabs(
                    labels: [
                      AppStrings.aboutArticle.tr(),
                      AppStrings.reviews.tr(),
                      AppStrings.similarArticle.tr(),
                    ],
                    selectedIndex: _tabController.index,
                    onChanged: _tabController.animateTo,
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                AboutArticleTab(article: article),
                ReviewsTab(
                  article: article,
                  comments: state.comments,
                  loadingMore: state.commentsStatus == ListStatus.loadingMore,
                  onLoadMore: () =>
                      context.read<ArticleCubit>().loadMoreComments(),
                ),
                SimilarTab(
                  items: state.similar,
                  loadingMore: state.similarStatus == ListStatus.loadingMore,
                  onLoadMore: () =>
                      context.read<ArticleCubit>().loadMoreSimilar(),
                  onItemTap: (a) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleScreen(articleId: a.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ---- Header: blurred-cover hero, with the sheet's rounded top ----
  Widget _buildHeader(BuildContext context, ArticleState state) {
    final article = state.article!;
    final media = MediaQuery.of(context);
    // Same share of the screen as the issue details hero.
    final heroHeight = media.size.height * 0.5;

    return SliverAppBar(
      pinned: true,
      expandedHeight: heroHeight - media.padding.top,
      backgroundColor: const Color(0xFF2A2A2A),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Text(
        AppStrings.article.tr(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: false,
      actions: [
        DetailCircleAction(
          asset: AppImages.openBook,
          onTap: () {
            final url = article.url;
            if (url == null || url.isEmpty) {
              Helpers.showError(AppStrings.somethingWentWrong.tr());
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WebViewScreen(url: url, title: article.title),
              ),
            );
          },
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        DetailFavoriteAction(
          isFavorite: article.isFavorite,
          onTap: () => context.read<ArticleCubit>().toggleFavorite(),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            DetailHero(
              coverUrl: article.image,
              title: article.title,
              // The app bar above draws the back/title/actions row.
              topBar: null,
              bottomSpacing: _sheetRadius + AppDimensions.paddingMedium,
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _sheetRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(_sheetRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Bottom bar (switches by tab) ----
  Widget? _buildBottomBar(BuildContext context) {
    final state = context.watch<ArticleCubit>().state;
    final article = state.article;
    if (article == null) return null;

    final isReviews = _tabController.index == 1;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: isReviews
            ? (article.allowedRating
                  ? CustomButton(
                      text: AppStrings.addRating.tr(),
                      isLoading: state.submittingRating,
                      onPressed: _openRating,
                    )
                  : const SizedBox.shrink())
            : Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: AppStrings.gift.tr(),
                      isOutlined: true,
                      textColor: AppColors.primary,
                      onPressed: () {
                        /* TODO: gift */
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: article.isFree
                          ? AppStrings.addToCart.tr()
                          : '${AppStrings.addToCart.tr()} ${article.price.toStringAsFixed(2)}${AppStrings.currencySar.tr()}',
                      isLoading: isAddingToCart,
                      onPressed: () =>
                          addToCart(type: CartItemType.article, id: article.id),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Pinned tab row for the NestedScrollView.
class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final Widget child;

  _TabsDelegate({required this.selectedIndex, required this.child});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: AppColors.cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      alignment: AlignmentDirectional.centerStart,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _TabsDelegate oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex || oldDelegate.child != child;
}
