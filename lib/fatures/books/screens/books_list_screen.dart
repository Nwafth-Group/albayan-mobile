
// ============================================
// FILE: lib/fatures/books/screens/books_list_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/books_remote_data_source.dart';
import 'book_screen.dart';
import 'cubit/books_list_cubit.dart';
import 'widgets/book_grid_card.dart';
import 'widgets/books_search_bar.dart';

class BooksListScreen extends StatelessWidget {
  const BooksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = BooksRemoteDataSourceImpl(ApiService());
        return BooksListCubit(dataSource)..load();
      },
      child: const _BooksListView(),
    );
  }
}

class _BooksListView extends StatefulWidget {
  const _BooksListView();

  @override
  State<_BooksListView> createState() => _BooksListViewState();
}

class _BooksListViewState extends State<_BooksListView> {
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
      context.read<BooksListCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.booksTab.tr()),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium),
              child: BooksSearchBar(
                controller: _searchController,
                onChanged: (q) => context.read<BooksListCubit>().search(q),
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
    return BlocBuilder<BooksListCubit, BooksListState>(
      builder: (context, state) {
        switch (state.status) {
          case BooksListStatus.initial:
          case BooksListStatus.loading:
            return const LoadingIndicator();

          case BooksListStatus.failure:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
              actionText: AppStrings.retry.tr(),
              onAction: () => context.read<BooksListCubit>().refresh(),
            );

          case BooksListStatus.empty:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.noBooks.tr(),
            );

          case BooksListStatus.success:
          case BooksListStatus.loadingMore:
            return _BooksGrid(
              scrollController: _scrollController,
              state: state,
              onRefresh: () => context.read<BooksListCubit>().refresh(),
            );
        }
      },
    );
  }
}

class _BooksGrid extends StatelessWidget {
  final ScrollController scrollController;
  final BooksListState state;
  final Future<void> Function() onRefresh;

  const _BooksGrid({
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
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              AppDimensions.paddingSmall,
              AppDimensions.paddingMedium,
              0,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppDimensions.paddingMedium,
                crossAxisSpacing: AppDimensions.paddingMedium,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = state.books[index];
                  return BookGridCard(
                    book: book,
                    onTap: () {
                      AppNavigator.push(BookScreen(bookId: book.id));
                    },
                    onCartTap: () {
                      // TODO: add to cart.
                    },
                  );
                },
                childCount: state.books.length,
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
