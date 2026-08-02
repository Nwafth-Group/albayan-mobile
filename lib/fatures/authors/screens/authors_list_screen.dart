// ============================================
// FILE: lib/fatures/authors/screens/authors_list_screen.dart
// ============================================

import 'package:albayan/fatures/authors/screens/author_screen.dart';
import 'package:albayan/fatures/corners/screens/widgets/corners_list_search_bar.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/authors_remote_data_source.dart';
import 'cubit/authors_list_cubit.dart';
import 'widgets/author_list_card.dart';

class AuthorsListScreen extends StatelessWidget {
  const AuthorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final api = ApiService();
        final dataSource = AuthorsRemoteDataSourceImpl(api);
        return AuthorsListCubit(dataSource)..load();
      },
      child: const _AuthorsListView(),
    );
  }
}

class _AuthorsListView extends StatefulWidget {
  const _AuthorsListView();

  @override
  State<_AuthorsListView> createState() => _AuthorsListViewState();
}

class _AuthorsListViewState extends State<_AuthorsListView> {
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
      context.read<AuthorsListCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.authorsTitle.tr()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingSmall),
              CornersListSearchBar(
                controller: _searchController,
                onChanged: (q) => context.read<AuthorsListCubit>().search(q),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AuthorsListCubit, AuthorsListState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthorsListStatus.initial:
          case AuthorsListStatus.loading:
            return const LoadingIndicator();

          case AuthorsListStatus.failure:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
              actionText: AppStrings.retry.tr(),
              onAction: () => context.read<AuthorsListCubit>().refresh(),
            );

          case AuthorsListStatus.empty:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.noAuthors.tr(),
            );

          case AuthorsListStatus.success:
          case AuthorsListStatus.loadingMore:
            return _AuthorsGrid(
              scrollController: _scrollController,
              state: state,
              onRefresh: () => context.read<AuthorsListCubit>().refresh(),
            );
        }
      },
    );
  }
}

class _AuthorsGrid extends StatelessWidget {
  final ScrollController scrollController;
  final AuthorsListState state;
  final Future<void> Function() onRefresh;

  const _AuthorsGrid({
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
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimensions.paddingLarge,
                crossAxisSpacing: AppDimensions.paddingSmall,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final author = state.authors[index];
                  return AuthorListCard(
                    author: author,
                    onTap: () {
                      AppNavigator.push(AuthorScreen(authorId: author.id));
                    },
                  );
                },
                childCount: state.authors.length,
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
