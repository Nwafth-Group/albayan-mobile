// ============================================
// FILE: lib/fatures/issues/screens/issues_screen.dart
// ============================================

import 'package:albayan/fatures/issues/screens/issue_details_screen.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:albayan/widgets/filter_bottom_sheet.dart';
import 'package:albayan/widgets/issue_card.dart';
import 'package:albayan/widgets/issues_filter.dart';
import 'package:albayan/widgets/issues_search_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/issues_remote_data_source.dart';
import 'cubit/issues_cubit.dart';


class IssuesScreen extends StatelessWidget {
  /// Optional starting filter (e.g. preselected year).
  final IssuesFilter? initialFilter;

  const IssuesScreen({super.key, this.initialFilter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final api = ApiService();
        final dataSource = IssuesRemoteDataSourceImpl(api);
        return IssuesCubit(dataSource, initialFilter: initialFilter)
          ..loadIssues();
      },
      child: const _IssuesView(),
    );
  }
}

class _IssuesView extends StatefulWidget {
  const _IssuesView();

  @override
  State<_IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<_IssuesView> {
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
      context.read<IssuesCubit>().loadMore();
    }
  }

  Future<void> _openFilter() async {
    final cubit = context.read<IssuesCubit>();
    final result =
    await showIssuesFilterSheet(context, current: cubit.state.filter);
    if (result == null) return; // dismissed

    if (result.action == FilterAction.reset) {
      _searchController.clear();          // clear the issue-number box
      await cubit.resetFilter();          // back to first-open defaults
    } else {
      await cubit.applyFilter(result.filter!);
    }
  }

  String get _titleYear {
    final year =
        context.read<IssuesCubit>().state.filter.year ?? DateTime.now().year;
    return AppStrings.issuesTitle.tr(namedArgs: {'year': '$year'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: _titleYear),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingSmall),
              BlocBuilder<IssuesCubit, IssuesState>(
                buildWhen: (a, b) =>
                a.filter.hasDateFilter != b.filter.hasDateFilter,
                builder: (context, state) {
                  return IssuesSearchBar(
                    controller: _searchController,
                    filterActive: state.filter.hasDateFilter,
                    onChanged: (q) => context.read<IssuesCubit>().search(q),
                    onFilterTap: _openFilter,
                  );
                },
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
    return BlocBuilder<IssuesCubit, IssuesState>(
      builder: (context, state) {
        switch (state.status) {
          case IssuesStatus.initial:
          case IssuesStatus.loading:
            return const LoadingIndicator();

          case IssuesStatus.failure:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
              actionText: AppStrings.retry.tr(),
              onAction: () => context.read<IssuesCubit>().refresh(),
            );

          case IssuesStatus.empty:
            final year = state.filter.year ?? DateTime.now().year;
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.noIssuesAvailable
                  .tr(namedArgs: {'year': '$year'}),
              message2: AppStrings.checkBackLater.tr(),
            );

          case IssuesStatus.success:
          case IssuesStatus.loadingMore:
            return _IssuesGrid(
              scrollController: _scrollController,
              state: state,
              onRefresh: () => context.read<IssuesCubit>().refresh(),
            );
        }
      },
    );
  }
}

class _IssuesGrid extends StatelessWidget {
  final ScrollController scrollController;
  final IssuesState state;
  final Future<void> Function() onRefresh;

  const _IssuesGrid({
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
                crossAxisCount: 2,
                mainAxisSpacing: AppDimensions.paddingLarge,
                crossAxisSpacing: AppDimensions.paddingMedium,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final issue = state.issues[index];
                  return IssueCard(
                    issue: issue,
                    onTap: () {
                      AppNavigator.push(IssueDetailsScreen(issueId: issue.id));
                    },
                  );
                },
                childCount: state.issues.length,
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
