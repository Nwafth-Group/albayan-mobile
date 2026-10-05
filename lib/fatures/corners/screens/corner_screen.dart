// ============================================
// FILE: lib/fatures/corners/screens/corner_screen.dart
// ============================================

import 'package:albayan/fatures/articles/screens/article_screen.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/promo_banner.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../cart/screens/cart_screen.dart';
import '../../cart/utils/add_to_cart_mixin.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../data/datasource/corners_remote_data_source.dart';
import 'cubit/corner_cubit.dart';
import 'widgets/corner_article_card.dart';
import 'widgets/corner_header.dart';
import 'widgets/corners_search_bar.dart';
import 'widgets/filter_bottom_sheet.dart';

class CornerScreen extends StatelessWidget {
  final String cornerId;

  const CornerScreen({super.key, required this.cornerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final api = ApiService();
        final dataSource = CornersRemoteDataSourceImpl(api);
        return CornerCubit(dataSource, cornerId: cornerId)..load();
      },
      child: const _CornerView(),
    );
  }
}

class _CornerView extends StatefulWidget {
  const _CornerView();

  @override
  State<_CornerView> createState() => _CornerViewState();
}

class _CornerViewState extends State<_CornerView> with AddToCartStateMixin {
  /// The promo banner sits after this many articles (per the design).
  static const _bannerAfter = 2;

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
      context.read<CornerCubit>().loadMore();
    }
  }

  Future<void> _openFilter() async {
    final cubit = context.read<CornerCubit>();
    final result = await showCornerFilterSheet(
      context,
      startDate: cubit.state.filter.startDate,
      endDate: cubit.state.filter.endDate,
    );
    if (result == null) return;
    if (result.action == FilterAction.reset) {
      await cubit.resetDates();
    } else {
      await cubit.applyDates(start: result.startDate, end: result.endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: context.select<CornerCubit, String>(
          (c) => c.state.corner?.name ?? '',
        ),
        color: AppColors.textPrimary,
        titleFontSize: AppDimensions.fontSizeXLarge,
        titleFontWeight: FontWeight.w600,
        actions: [
          _HeaderIcon(
            asset: AppImages.cart,
            fallbackIcon: Icons.shopping_cart_outlined,
            onTap: () => AppNavigator.push(const CartScreen(showAppBar: true)),
          ),
          const SizedBox(width: 10),
          _HeaderIcon(
            asset: AppImages.notification,
            fallbackIcon: Icons.notifications_outlined,
            onTap: () => AppNavigator.push(const NotificationsScreen()),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
        ],
      ),
      body: BlocBuilder<CornerCubit, CornerState>(
        builder: (context, state) {
          // Full-screen loading on first load.
          if (state.isLoading && state.articles.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Failure on first load.
          if (state.status == CornerStatus.failure && state.articles.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.wifi_off_rounded,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error,
              actionText: AppStrings.retry.tr(),
              onAction: () => context.read<CornerCubit>().load(),
            );
          }

          final articles = state.articles;
          final hasBanner = articles.isNotEmpty;
          // Banner goes after the 2nd article, or after the last one when
          // there are fewer.
          final bannerIndex = articles.length < _bannerAfter
              ? articles.length
              : _bannerAfter;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<CornerCubit>().refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Search + filter (top of page)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingxSmall,
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingMedium,
                    ),
                    child: CornersSearchBar(
                      controller: _searchController,
                      filterActive: state.filter.hasDates,
                      onChanged: (v) => context.read<CornerCubit>().search(v),
                      onFilterTap: _openFilter,
                    ),
                  ),
                ),

                // Header banner
                if (state.corner != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall,
                      ),
                      child: CornerHeader(corner: state.corner!),
                    ),
                  ),

                // Empty state
                if (state.status == CornerStatus.empty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      image: AppImages.noData,
                      message: AppStrings.noArticles.tr(),
                    ),
                  ),

                // Article list, with the promo banner slotted in
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (hasBanner && index == bannerIndex) {
                      return const AdPromoBanner(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingSmall,
                        ),
                      );
                    }
                    final articleIndex = hasBanner && index > bannerIndex
                        ? index - 1
                        : index;
                    final article = articles[articleIndex];
                    return CornerArticleCard(
                      article: article,
                      onTap: () {
                        AppNavigator.push(ArticleScreen(articleId: article.id));
                      },
                      onFavoriteTap: () => context
                          .read<CornerCubit>()
                          .toggleFavorite(article.id),
                      onCartTap: () =>
                          addToCart(type: CartItemType.article, id: article.id),
                    );
                  }, childCount: articles.length + (hasBanner ? 1 : 0)),
                ),

                // Loading-more spinner
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingLarge,
                      ),
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
        },
      ),
    );
  }
}

/// Round cream button in the app bar (cart / notifications).
class _HeaderIcon extends StatelessWidget {
  final String asset;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.asset,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.cardColor,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          asset,
          width: 20,
          height: 20,
          errorBuilder: (_, __, ___) =>
              Icon(fallbackIcon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }
}
