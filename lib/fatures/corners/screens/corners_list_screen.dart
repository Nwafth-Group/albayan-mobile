// ============================================
// FILE: lib/fatures/corners/screens/corners_list_screen.dart
// ============================================

import 'package:albayan/fatures/corners/screens/corner_screen.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/corners_remote_data_source.dart';
import 'cubit/corners_list_cubit.dart';
import 'widgets/corner_list_card.dart';
import 'widgets/corners_list_search_bar.dart';

class CornersListScreen extends StatelessWidget {
  const CornersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final api = ApiService();
        final dataSource = CornersRemoteDataSourceImpl(api);
        return CornersListCubit(dataSource)..load();
      },
      child: const _CornersListView(),
    );
  }
}

class _CornersListView extends StatefulWidget {
  const _CornersListView();

  @override
  State<_CornersListView> createState() => _CornersListViewState();
}

class _CornersListViewState extends State<_CornersListView> {
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
      context.read<CornersListCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.cornersTitle.tr()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingSmall),
              CornersListSearchBar(
                controller: _searchController,
                onChanged: (q) => context.read<CornersListCubit>().search(q),
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
    return BlocBuilder<CornersListCubit, CornersListState>(
      builder: (context, state) {
        switch (state.status) {
          case CornersListStatus.initial:
          case CornersListStatus.loading:
            return const LoadingIndicator();

          case CornersListStatus.failure:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.somethingWentWrong.tr(),
              message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
              actionText: AppStrings.retry.tr(),
              onAction: () => context.read<CornersListCubit>().refresh(),
            );

          case CornersListStatus.empty:
            return EmptyStateWidget(
              image: AppImages.noData,
              message: AppStrings.noCorners.tr(),
            );

          case CornersListStatus.success:
          case CornersListStatus.loadingMore:
            return _CornersGrid(
              scrollController: _scrollController,
              state: state,
              onRefresh: () => context.read<CornersListCubit>().refresh(),
            );
        }
      },
    );
  }
}

class _CornersGrid extends StatelessWidget {
  final ScrollController scrollController;
  final CornersListState state;
  final Future<void> Function() onRefresh;

  const _CornersGrid({
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
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final corner = state.corners[index];
                  return CornerListCard(
                    corner: corner,
                    onTap: () {
                      AppNavigator.push(CornerScreen(cornerId: corner.id));
                    },
                  );
                },
                childCount: state.corners.length,
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
