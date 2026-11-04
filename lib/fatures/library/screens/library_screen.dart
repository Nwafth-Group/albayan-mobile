// ============================================
// FILE: lib/fatures/library/screens/library_screen.dart
// ============================================

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../favorites/screens/favorites_tab.dart';
import '../../settings/screens/widgets/settings_widgets.dart';
import '../data/datasource/library_remote_data_source.dart';
import '../data/models/library_section_model.dart';
import '../data/models/library_summary_model.dart';
import '../data/models/personal_category_model.dart';
import 'cubit/library_summary_cubit.dart';
import 'cubit/personal_categories_cubit.dart';
import 'personal_category_screen.dart';
import 'library_books_screen.dart';
import 'library_documents_screen.dart';
import 'library_magazine_screen.dart';
import 'widgets/library_category_sheets.dart';
import 'widgets/library_guest_view.dart';
import 'widgets/library_section_card.dart';
import 'widgets/library_refreshable.dart';
import 'widgets/library_tabs.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = LibrarySummaryCubit(
          LibraryRemoteDataSourceImpl(ApiService()),
        );
        // A guest has no library — skip the request that would fail (401).
        if (SharedPrefHelper.isLoggedIn()) cubit.load();
        return cubit;
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
      appBar: CustomAppBar(
        showBack: false,
        centerTitle: true,
        title: AppStrings.libraryTitle.tr(),
        color: AppColors.textPrimary,
        titleFontSize: AppDimensions.fontSizeXLarge,
        titleFontWeight: FontWeight.w500,
      ),
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
    if (!SharedPrefHelper.isLoggedIn()) {
      return LibraryGuestView(
        icon: _tabIndex == 2
            ? Icons.favorite_border
            : Icons.local_library_outlined,
        message: _tabIndex == 2
            ? AppStrings.loginToUseFavorites.tr()
            : AppStrings.loginToViewLibrary.tr(),
      );
    }
    switch (_tabIndex) {
      case 0:
        return _MyLibraryTab(onOpenSection: (type) => _openSection(type));
      case 1:
        return const _CategoriesTab();
      default:
        return const FavoritesTab();
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
            return LibraryRefreshable(
              onRefresh: () => context.read<LibrarySummaryCubit>().refresh(),
              child: EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.somethingWentWrong.tr(),
                message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                actionText: AppStrings.retry.tr(),
                onAction: () => context.read<LibrarySummaryCubit>().load(),
              ),
            );

          case LibrarySummaryStatus.success:
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<LibrarySummaryCubit>().refresh(),
              child: _SectionsGrid(
                summary: state.summary,
                onOpenSection: onOpenSection,
              ),
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
      physics: const AlwaysScrollableScrollPhysics(),
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
      create: (_) =>
          PersonalCategoriesCubit(LibraryRemoteDataSourceImpl(ApiService()))
            ..load(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  Future<void> _addCategory(BuildContext context) async {
    final cubit = context.read<PersonalCategoriesCubit>();
    final name = await showAddCategorySheet(context);
    if (name == null) return;
    if (await cubit.create(name)) {
      AppNavigator.showSuccessSnackBar(AppStrings.libraryCategoryCreated.tr());
    }
  }

  /// A category that still holds items can't be deleted — show the error
  /// sheet instead of the confirmation.
  Future<void> _deleteCategory(
    BuildContext context,
    PersonalCategoryModel category,
  ) async {
    final cubit = context.read<PersonalCategoriesCubit>();
    if (category.itemsCount > 0) {
      await showSettingsSheet(
        context,
        title: AppStrings.libraryDeleteCategoryErrorTitle.tr(),
        titleColor: AppColors.primary,
        message: AppStrings.libraryDeleteCategoryNotEmpty.tr(),
        primaryText: AppStrings.cancel.tr(),
      );
      return;
    }
    final confirmed = await showSettingsSheet(
      context,
      title: AppStrings.libraryDeleteCategoryTitle.tr(),
      titleColor: AppColors.primary,
      message: AppStrings.libraryDeleteCategoryMessage.tr(),
      primaryText: AppStrings.libraryYesDelete.tr(),
      secondaryText: AppStrings.cancel.tr(),
    );
    if (confirmed != true) return;
    if (await cubit.delete(category.id)) {
      AppNavigator.showSuccessSnackBar(AppStrings.libraryCategoryDeleted.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'library_add_category',
        onPressed: () => _addCategory(context),
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: const Icon(Icons.add, color: AppColors.white, size: 30),
      ),
      body: BlocBuilder<PersonalCategoriesCubit, PersonalCategoriesState>(
        builder: (context, state) {
          final cubit = context.read<PersonalCategoriesCubit>();
          switch (state.status) {
            case PersonalCategoriesStatus.initial:
            case PersonalCategoriesStatus.loading:
              return const LoadingIndicator();

            case PersonalCategoriesStatus.failure:
              return LibraryRefreshable(
                onRefresh: cubit.refresh,
                child: EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.somethingWentWrong.tr(),
                  message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                  actionText: AppStrings.retry.tr(),
                  onAction: cubit.load,
                ),
              );

            case PersonalCategoriesStatus.empty:
              return LibraryRefreshable(
                onRefresh: cubit.refresh,
                child: EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.libraryNoCategoryTitle.tr(),
                  message2: AppStrings.libraryAddNewCategory.tr(),
                ),
              );

            case PersonalCategoriesStatus.success:
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: cubit.refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingMedium,
                    0,
                    AppDimensions.paddingMedium,
                    // Room for the FAB over the last tile.
                    96,
                  ),
                  itemCount: state.categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimensions.paddingSmall),
                  itemBuilder: (_, i) {
                    final category = state.categories[i];
                    return _SwipeToDelete(
                      key: ValueKey(category.id),
                      onDelete: () => _deleteCategory(context, category),
                      child: _CategoryTile(
                        category: category,
                        onTap: () => AppNavigator.push(
                          PersonalCategoryScreen(category: category),
                        ),
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

/// Swiping the tile towards the start reveals a trash button at its end.
class _SwipeToDelete extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;

  const _SwipeToDelete({
    super.key,
    required this.child,
    required this.onDelete,
  });

  @override
  State<_SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<_SwipeToDelete> {
  static const double _buttonSize = 56;
  static const double _revealWidth = _buttonSize + AppDimensions.paddingSmall;

  /// 0 (closed) to [_revealWidth] (open).
  double _offset = 0;
  bool _dragging = false;

  bool get _isRtl => Directionality.of(context) == ui.TextDirection.rtl;

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = _isRtl ? d.delta.dx : -d.delta.dx;
    setState(() {
      _dragging = true;
      _offset = (_offset + delta).clamp(0.0, _revealWidth);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    setState(() {
      _dragging = false;
      _offset = _offset > _revealWidth / 2 ? _revealWidth : 0;
    });
  }

  void _close() => setState(() => _offset = 0);

  @override
  Widget build(BuildContext context) {
    final open = _offset > 0;
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [
          if (open)
            PositionedDirectional(
              end: 0,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  onTap: () {
                    _close();
                    widget.onDelete();
                  },
                  child: const SizedBox(
                    width: _buttonSize,
                    height: _buttonSize,
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          AnimatedContainer(
            duration: _dragging
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              _isRtl ? _offset : -_offset,
              0,
              0,
            ),
            child: AbsorbPointer(
              // While open, a tap on the tile just closes it.
              absorbing: open,
              child: widget.child,
            ),
          ),
          if (open)
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              end: _revealWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final PersonalCategoryModel category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.folder,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.libraryItemsCount.tr(
                        namedArgs: {'count': '${category.itemsCount}'},
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
