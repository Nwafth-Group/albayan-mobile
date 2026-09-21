
// ============================================
// FILE: lib/fatures/library/screens/library_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/library_remote_data_source.dart';
import '../data/models/library_section_model.dart';
import '../data/models/library_summary_model.dart';
import '../data/models/personal_category_model.dart';
import 'cubit/library_summary_cubit.dart';
import 'cubit/personal_categories_cubit.dart';
import 'personal_categories_screen.dart';
import 'library_books_screen.dart';
import 'library_documents_screen.dart';
import 'library_magazine_screen.dart';
import 'widgets/library_section_card.dart';
import 'widgets/library_tabs.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = LibraryRemoteDataSourceImpl(ApiService());
        return LibrarySummaryCubit(dataSource)..load();
      },
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatefulWidget {
  const _LibraryView();

  @override
  State<_LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<_LibraryView> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppStrings.libraryTabMyLibrary.tr(),
      AppStrings.libraryTabCategories.tr(),
      AppStrings.libraryTabFavorites.tr(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingMedium),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: LibraryTabs(
                labels: labels,
                selectedIndex: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabIndex) {
      case 0:
        return _MyLibraryTab(
          onOpenSection: (type) => _openSection(type),
        );
      case 1:
        return const _CategoriesTab();
      default:
        return EmptyStateWidget(
          image: AppImages.noData,
          message: AppStrings.libraryNoFavorites.tr(),
        );
    }
  }

  void _openSection(LibrarySectionType type) {
    switch (type) {
      case LibrarySectionType.books:
        AppNavigator.push(const LibraryBooksScreen());
        break;
      case LibrarySectionType.documents:
        AppNavigator.push(const LibraryDocumentsScreen());
        break;
      case LibrarySectionType.magazine:
        AppNavigator.push(const LibraryMagazineScreen());
        break;
    }
  }
}

class _MyLibraryTab extends StatelessWidget {
  final void Function(LibrarySectionType type) onOpenSection;

  const _MyLibraryTab({required this.onOpenSection});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibrarySummaryCubit, LibrarySummaryState>(
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
              onAction: () => context.read<LibrarySummaryCubit>().load(),
            );

          case LibrarySummaryStatus.success:
            return _SectionsGrid(
              summary: state.summary,
              onOpenSection: onOpenSection,
            );
        }
      },
    );
  }
}

class _SectionsGrid extends StatelessWidget {
  final LibrarySummaryModel summary;
  final void Function(LibrarySectionType type) onOpenSection;

  const _SectionsGrid({required this.summary, required this.onOpenSection});

  @override
  Widget build(BuildContext context) {
    final sections = [
      LibrarySectionModel(
        type: LibrarySectionType.books,
        titleKey: AppStrings.libraryBooks,
        countKey: AppStrings.libraryBooksCount,
        count: summary.booksCount,
      ),
      LibrarySectionModel(
        type: LibrarySectionType.documents,
        titleKey: AppStrings.libraryMyDocuments,
        countKey: AppStrings.libraryDocumentsCount,
        count: summary.myDocumentsCount,
      ),
      LibrarySectionModel(
        type: LibrarySectionType.magazine,
        titleKey: AppStrings.libraryAlbayanMagazine,
        countKey: AppStrings.libraryItemsCount,
        count: summary.magazineTotalCount,
      ),
    ];

    // if (summary.booksCount == 0 &&
    //     summary.myDocumentsCount == 0 &&
    //     summary.magazineTotalCount == 0) {
    //   return EmptyStateWidget(
    //     image: AppImages.noData,
    //     message: AppStrings.libraryEmptyTitle.tr(),
    //     message2: AppStrings.libraryEmptySubtitle.tr(),
    //   );
    // }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        0,
        AppDimensions.paddingMedium,
        AppDimensions.paddingLarge,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingMedium,
        mainAxisSpacing: AppDimensions.paddingMedium,
        childAspectRatio: 1.3,
      ),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        return LibrarySectionCard(
          section: sections[index],
          color: index.isEven
              ? AppColors.surfaceVariant
              : AppColors.surfaceDark,
          onTap: () => onOpenSection(sections[index].type),
        );
      },
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalCategoriesCubit(
        LibraryRemoteDataSourceImpl(ApiService()),
      )..load(),
      child: BlocBuilder<PersonalCategoriesCubit, PersonalCategoriesState>(
        builder: (context, state) {
          switch (state.status) {
            case PersonalCategoriesStatus.initial:
            case PersonalCategoriesStatus.loading:
              return const LoadingIndicator();

            case PersonalCategoriesStatus.failure:
              return EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.somethingWentWrong.tr(),
                message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                actionText: AppStrings.retry.tr(),
                onAction: () => context.read<PersonalCategoriesCubit>().load(),
              );

            case PersonalCategoriesStatus.empty:
            case PersonalCategoriesStatus.success:
              final cards = [
                (PersonalCategoryType.book, AppStrings.libraryBooks,
                    AppStrings.libraryBooksCount),
                (PersonalCategoryType.issue,
                    AppStrings.libraryMagazineIssuesTab,
                    AppStrings.libraryIssuesCount),
                (PersonalCategoryType.article,
                    AppStrings.libraryMagazineArticlesTab,
                    AppStrings.libraryArticlesCount),
              ];
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  0,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.paddingMedium,
                  mainAxisSpacing: AppDimensions.paddingMedium,
                  childAspectRatio: 1.3,
                ),
                itemCount: cards.length,
                itemBuilder: (context, i) {
                  final (type, titleKey, countKey) = cards[i];
                  return LibrarySectionCard(
                    section: LibrarySectionModel(
                      type: LibrarySectionType.magazine,
                      titleKey: titleKey,
                      countKey: countKey,
                      count: state.counts.countOf(type),
                    ),
                    color: i.isEven
                        ? AppColors.surfaceVariant
                        : AppColors.surfaceDark,
                    onTap: () =>
                        AppNavigator.push(PersonalCategoriesScreen(type: type)),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
