
// ============================================
// FILE: lib/fatures/favorites/screens/favorites_tab.dart
// ============================================
//
// The Library's "Favorites" tab: GET /reader/favorites, paginated.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../articles/screens/article_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../books/screens/book_screen.dart';
import '../../issues/screens/issue_details_screen.dart';
import '../data/datasource/favorites_remote_data_source.dart';
import '../data/models/favorite_item_model.dart';
import 'cubit/favorites_cubit.dart';
import 'widgets/favorite_item_card.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Favorites live on the reader's account — a guest gets a login prompt
    // instead of a request that would only return 401.
    if (!SharedPrefHelper.isLoggedIn()) {
      return EmptyStateWidget(
        image: AppImages.noData,
        message: AppStrings.guestModeTitle.tr(),
        message2: AppStrings.loginToUseFavorites.tr(),
        actionText: AppStrings.login.tr(),
        onAction: () => AppNavigator.push(const LoginScreen()),
      );
    }

    return BlocProvider(
      create: (_) =>
          FavoritesCubit(FavoritesRemoteDataSourceImpl(ApiService()))..load(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatefulWidget {
  const _FavoritesView();

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {
  final _scrollController = ScrollController();

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
      context.read<FavoritesCubit>().loadMore();
    }
  }

  void _open(FavoriteItemModel item) {
    switch (item.type) {
      case FavoriteType.book:
        AppNavigator.push(BookScreen(bookId: item.itemId));
        break;
      case FavoriteType.issue:
        AppNavigator.push(IssueDetailsScreen(issueId: item.itemId));
        break;
      case FavoriteType.article:
        AppNavigator.push(ArticleScreen(articleId: item.itemId));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final cubit = context.read<FavoritesCubit>();
        switch (state.status) {
          case FavoritesStatus.initial:
          case FavoritesStatus.loading:
            return const LoadingIndicator();

          case FavoritesStatus.failure:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
              actionText: AppStrings.retry.tr(),
              onAction: cubit.load,
            );

          case FavoritesStatus.empty:
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: cubit.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: EmptyStateWidget(
                      image: AppImages.noData,
                      message: AppStrings.libraryNoFavorites.tr(),
                    ),
                  ),
                ],
              ),
            );

          case FavoritesStatus.success:
          case FavoritesStatus.loadingMore:
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: cubit.refresh,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingLarge,
                ),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingMedium,
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
                    );
                  }
                  final item = state.items[index];
                  return FavoriteItemCard(
                    // Keyed so removing a row doesn't hand its image to the
                    // next one.
                    key: ValueKey('${item.type.name}:${item.itemId}'),
                    item: item,
                    onTap: () => _open(item),
                    onUnfavorite: () => cubit.unfavorite(item),
                  );
                },
              ),
            );
        }
      },
    );
  }
}
