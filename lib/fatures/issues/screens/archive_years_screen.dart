// ============================================
// FILE: lib/fatures/issues/screens/archive_years_screen.dart
// ============================================
//
// Settings → Archive: the years from `GET /public/issues/archive-years`.
// Tapping a year opens the issues list filtered to it
// (`GET /public/issues?year=...`), where issue number / date range
// filters are available.

import 'dart:ui' as ui;

import 'package:albayan/widgets/issues_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/issues_remote_data_source.dart';
import '../data/models/archive_year_model.dart';
import 'cubit/archive_years_cubit.dart';
import 'issues_screen.dart';

class ArchiveYearsScreen extends StatelessWidget {
  const ArchiveYearsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArchiveYearsCubit(IssuesRemoteDataSourceImpl(ApiService()))..load(),
      child: const _ArchiveYearsView(),
    );
  }
}

class _ArchiveYearsView extends StatefulWidget {
  const _ArchiveYearsView();

  @override
  State<_ArchiveYearsView> createState() => _ArchiveYearsViewState();
}

class _ArchiveYearsViewState extends State<_ArchiveYearsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<ArchiveYearsCubit>().loadMore();
    }
  }

  void _openYear(ArchiveYearModel year) {
    // `year` is sent as the Gregorian year, matching the issues list's
    // default (current Gregorian year) and its "Issues , {year}" title.
    AppNavigator.push(
      IssuesScreen(initialFilter: IssuesFilter(year: year.gYear)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.settingsArchive.tr(),
        color: AppColors.textPrimary,
        titleFontSize: 18,
        titleFontWeight: FontWeight.w500,
      ),
      body: BlocBuilder<ArchiveYearsCubit, ArchiveYearsState>(
        builder: (context, state) {
          final cubit = context.read<ArchiveYearsCubit>();
          switch (state.status) {
            case ArchiveYearsStatus.initial:
            case ArchiveYearsStatus.loading:
              return const LoadingIndicator();

            case ArchiveYearsStatus.failure:
              return _Refreshable(
                onRefresh: cubit.refresh,
                child: EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.somethingWentWrong.tr(),
                  message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                  actionText: AppStrings.retry.tr(),
                  onAction: cubit.load,
                ),
              );

            case ArchiveYearsStatus.empty:
              return _Refreshable(
                onRefresh: cubit.refresh,
                child: EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.noArchiveYears.tr(),
                ),
              );

            case ArchiveYearsStatus.success:
            case ArchiveYearsStatus.loadingMore:
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: cubit.refresh,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.years.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == state.years.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
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
                    final year = state.years[i];
                    return _YearTile(year: year, onTap: () => _openYear(year));
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _YearTile extends StatelessWidget {
  final ArchiveYearModel year;
  final VoidCallback onTap;

  const _YearTile({required this.year, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.accentPale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArchive,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.archiveYearLabel.tr(
                    namedArgs: {'h': '${year.hYear}', 'g': '${year.gYear}'},
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.accentPale,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRtl ? Icons.arrow_back : Icons.arrow_forward,
                  size: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Refreshable extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _Refreshable({required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
