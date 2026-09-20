
// ============================================
// FILE: lib/fatures/library/screens/library_magazine_screen.dart
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
import '../data/datasource/library_remote_data_source.dart';
import 'cubit/library_summary_cubit.dart';
import 'library_articles_screen.dart';
import 'library_issues_screen.dart';
import 'widgets/library_section_card.dart';
import '../data/models/library_section_model.dart';

class LibraryMagazineScreen extends StatelessWidget {
  const LibraryMagazineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = LibraryRemoteDataSourceImpl(ApiService());
        return LibrarySummaryCubit(dataSource)..load();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: AppStrings.libraryAlbayanMagazine.tr()),
        body: SafeArea(
          child: BlocBuilder<LibrarySummaryCubit, LibrarySummaryState>(
            builder: (context, state) {
              switch (state.status) {
                case LibrarySummaryStatus.initial:
                case LibrarySummaryStatus.loading:
                  return const LoadingIndicator();

                case LibrarySummaryStatus.failure:
                  return EmptyStateWidget(
                    image: AppImages.noData,
                    message: AppStrings.somethingWentWrong.tr(),
                    message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                    actionText: AppStrings.retry.tr(),
                    onAction: () =>
                        context.read<LibrarySummaryCubit>().load(),
                  );

                case LibrarySummaryStatus.success:
                  return GridView.count(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.paddingMedium,
                    mainAxisSpacing: AppDimensions.paddingMedium,
                    childAspectRatio: 1.3,
                    children: [
                      LibrarySectionCard(
                        section: LibrarySectionModel(
                          type: LibrarySectionType.magazine,
                          titleKey: AppStrings.libraryMagazineIssuesTab,
                          countKey: AppStrings.libraryIssuesCount,
                          count: state.summary.magazineIssuesCount,
                        ),
                        color: AppColors.surfaceVariant,
                        onTap: () =>
                            AppNavigator.push(const LibraryIssuesScreen()),
                      ),
                      LibrarySectionCard(
                        section: LibrarySectionModel(
                          type: LibrarySectionType.magazine,
                          titleKey: AppStrings.libraryMagazineArticlesTab,
                          countKey: AppStrings.libraryArticlesCount,
                          count: state.summary.magazineArticlesCount,
                        ),
                        color: AppColors.surfaceDark,
                        onTap: () =>
                            AppNavigator.push(const LibraryArticlesScreen()),
                      ),
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
