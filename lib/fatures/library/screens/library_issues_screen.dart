
// ============================================
// FILE: lib/fatures/library/screens/library_issues_screen.dart
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
import 'cubit/library_issues_cubit.dart';
import 'widgets/library_issue_card.dart';

class LibraryIssuesScreen extends StatelessWidget {
  const LibraryIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = LibraryRemoteDataSourceImpl(ApiService());
        return LibraryIssuesCubit(dataSource)..load();
      },
      child: const _LibraryIssuesView(),
    );
  }
}

class _LibraryIssuesView extends StatefulWidget {
  const _LibraryIssuesView();

  @override
  State<_LibraryIssuesView> createState() => _LibraryIssuesViewState();
}

class _LibraryIssuesViewState extends State<_LibraryIssuesView> {
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
      context.read<LibraryIssuesCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryMagazineIssuesTab.tr()),
      body: SafeArea(
        child: BlocBuilder<LibraryIssuesCubit, LibraryIssuesState>(
          builder: (context, state) {
            switch (state.status) {
              case LibraryIssuesStatus.initial:
              case LibraryIssuesStatus.loading:
                return const LoadingIndicator();

              case LibraryIssuesStatus.failure:
                return EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.somethingWentWrong.tr(),
                  message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                  actionText: AppStrings.retry.tr(),
                  onAction: () => context.read<LibraryIssuesCubit>().refresh(),
                );

              case LibraryIssuesStatus.empty:
                return EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.libraryNoItems.tr(),
                );

              case LibraryIssuesStatus.success:
              case LibraryIssuesStatus.loadingMore:
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<LibraryIssuesCubit>().refresh(),
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
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final issue = state.issues[index];
                              return LibraryIssueCard(
                                issue: issue,
                                onDelete: () => context
                                    .read<LibraryIssuesCubit>()
                                    .remove(issue.id),
                              );
                            },
                            childCount: state.issues.length,
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
