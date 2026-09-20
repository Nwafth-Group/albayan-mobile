
// ============================================
// FILE: lib/fatures/library/screens/library_books_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/library_remote_data_source.dart';
import 'cubit/library_books_cubit.dart';
import 'widgets/library_book_card.dart';

class LibraryBooksScreen extends StatelessWidget {
  const LibraryBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = LibraryRemoteDataSourceImpl(ApiService());
        return LibraryBooksCubit(dataSource)..load();
      },
      child: const _LibraryBooksView(),
    );
  }
}

class _LibraryBooksView extends StatefulWidget {
  const _LibraryBooksView();

  @override
  State<_LibraryBooksView> createState() => _LibraryBooksViewState();
}

class _LibraryBooksViewState extends State<_LibraryBooksView> {
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
      context.read<LibraryBooksCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryBooks.tr()),
      body: SafeArea(
        child: BlocBuilder<LibraryBooksCubit, LibraryBooksState>(
          builder: (context, state) {
            switch (state.status) {
              case LibraryBooksStatus.initial:
              case LibraryBooksStatus.loading:
                return const LoadingIndicator();

              case LibraryBooksStatus.failure:
                return EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.somethingWentWrong.tr(),
                  message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                  actionText: AppStrings.retry.tr(),
                  onAction: () => context.read<LibraryBooksCubit>().refresh(),
                );

              case LibraryBooksStatus.empty:
                return EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.noBooks.tr(),
                );

              case LibraryBooksStatus.success:
              case LibraryBooksStatus.loadingMore:
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<LibraryBooksCubit>().refresh(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingMedium,
                          AppDimensions.paddingMedium,
                          AppDimensions.paddingMedium,
                          0,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppDimensions.paddingMedium,
                            mainAxisSpacing: AppDimensions.paddingMedium,
                            childAspectRatio: 0.54,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final book = state.books[index];
                              return LibraryBookCard(
                                book: book,
                                onDelete: () => context
                                    .read<LibraryBooksCubit>()
                                    .remove(book.id),
                              );
                            },
                            childCount: state.books.length,
                          ),
                        ),
                      ),
                      if (state.isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingLarge),
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
                        child: SizedBox(height: AppDimensions.paddingLarge),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
