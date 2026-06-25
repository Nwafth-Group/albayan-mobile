
// ============================================
// FILE: lib/fatures/articles/screens/article_screen.dart
// ============================================

import 'package:albayan/widgets/custom_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state_widget.dart';
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
    with SingleTickerProviderStateMixin {
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
                    top: AppDimensions.paddingMedium,
                    bottom: AppDimensions.paddingSmall,
                  ),
                  child: ArticleInfoBar(article: article),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    dividerColor: AppColors.cardColor,
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textLight,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(text: AppStrings.aboutArticle.tr()),
                      Tab(text: AppStrings.reviews.tr()),
                      Tab(text: AppStrings.similarArticle.tr()),
                    ],
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

  // ---- Header (image + title) ----
  Widget _buildHeader(BuildContext context, ArticleState state) {
    final article = state.article!;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 320,
      backgroundColor: const Color(0xFF2A2A2A),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        AppStrings.article.tr(),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: false,
      actions: [
        _circleAction(
          child: ImageAsset(AppImages.openBook, width: 20, height: 20),
          onTap: () {/* TODO: open reader */},
        ),
        _circleAction(
          child: ImageAsset(AppImages.favorate, width: 20, height: 20),
          onTap: () => context.read<ArticleCubit>().toggleFavorite(),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (article.image != null)
              Image.network(
                article.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF2A2A2A)),
              )
            else
              Container(color: const Color(0xFF2A2A2A)),
            // Darken for legibility
            Container(color: Colors.black.withOpacity(0.45)),
            // Centered cover + title
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLarge),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: (article.image != null)
                            ? Image.network(article.image!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const ColoredBox(
                                color: AppColors.surfaceVariant))
                            : const ColoredBox(color: AppColors.surfaceVariant),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        article.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppDimensions.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleAction({required Widget child, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: child,
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
                icon: Icons.card_giftcard,
                textColor: AppColors.primary,
                onPressed: () {/* TODO: gift */},
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: article.isFree
                    ? AppStrings.addToCart.tr()
                    : '${AppStrings.addToCart.tr()} ${article.price.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
                onPressed: () {/* TODO: add to cart */},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinned TabBar header for the NestedScrollView.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: AppColors.cardColor,
      alignment: Alignment.centerLeft,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}