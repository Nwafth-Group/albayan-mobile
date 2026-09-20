
// ============================================
// FILE: lib/fatures/library/screens/library_articles_screen.dart
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
import 'cubit/library_articles_cubit.dart';
import 'widgets/library_article_card.dart';

class LibraryArticlesScreen extends StatelessWidget {
  const LibraryArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = LibraryRemoteDataSourceImpl(ApiService());
        return LibraryArticlesCubit(dataSource)..load();
      },
      child: const _LibraryArticlesView(),
    );
  }
}

class _LibraryArticlesView extends StatefulWidget {
  const _LibraryArticlesView();

  @override
  State<_LibraryArticlesView> createState() => _LibraryArticlesViewState();
}

class _LibraryArticlesViewState extends State<_LibraryArticlesView> {
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
      context.read<LibraryArticlesCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryMagazineArticlesTab.tr()),
      body: SafeArea(
        child: BlocBuilder<LibraryArticlesCubit, LibraryArticlesState>(
          builder: (context, state) {
            switch (state.status) {
              case LibraryArticlesStatus.initial:
              case LibraryArticlesStatus.loading:
                return const LoadingIndicator();

              case LibraryArticlesStatus.failure:
                return EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.somethingWentWrong.tr(),
                  message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                  actionText: AppStrings.retry.tr(),
                  onAction: () =>
                      context.read<LibraryArticlesCubit>().refresh(),
                );

              case LibraryArticlesStatus.empty:
                return EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.libraryNoItems.tr(),
                );

              case LibraryArticlesStatus.success:
              case LibraryArticlesStatus.loadingMore:
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<LibraryArticlesCubit>().refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingLarge,
                    ),
                    itemCount:
                        state.articles.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.paddingSmall),
                    itemBuilder: (context, index) {
                      if (index >= state.articles.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingMedium),
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
                      final article = state.articles[index];
                      return LibraryArticleCard(
                        article: article,
                        onDelete: () => context
                            .read<LibraryArticlesCubit>()
                            .remove(article.id),
                      );
                    },
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
