// ============================================
// FILE: lib/fatures/library/screens/personal_category_screen.dart
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
import '../../../widgets/web_view_screen.dart';
import '../../articles/screens/article_screen.dart';
import '../../books/screens/book_screen.dart';
import '../../issues/screens/issue_details_screen.dart';
import '../../reader/screens/reader_screen.dart';
import '../data/datasource/library_remote_data_source.dart';
import '../data/models/personal_category_model.dart';
import 'cubit/library_books_cubit.dart';
import 'cubit/personal_category_items_cubit.dart';
import 'widgets/library_article_card.dart';
import 'widgets/library_book_card.dart';
import 'widgets/library_category_sheets.dart';
import 'widgets/library_delete_badge.dart';
import 'widgets/library_issue_card.dart';
import 'widgets/library_refreshable.dart';
import 'widgets/library_tabs.dart';

/// Shows the add (FAB) and remove (trash badge) controls for category items.
const bool _itemEditingEnabled = true;

/// A personal category's items, split into Issues / Books / Articles tabs.
/// Each tab loads `GET /reader/personal-categories/{id}/items?type=` the
/// first time it's opened and keeps its list while switching tabs. The FAB
/// adds items of the selected tab's type from the reader's library.
class PersonalCategoryScreen extends StatefulWidget {
  final PersonalCategoryModel category;

  const PersonalCategoryScreen({super.key, required this.category});

  @override
  State<PersonalCategoryScreen> createState() => _PersonalCategoryScreenState();
}

class _PersonalCategoryScreenState extends State<PersonalCategoryScreen> {
  static const _types = [
    PersonalCategoryType.issue,
    PersonalCategoryType.book,
    PersonalCategoryType.article,
  ];

  int _tabIndex = 1;
  final _cubits = <PersonalCategoryType, PersonalCategoryItemsCubit>{};

  /// Created the first time its tab is opened.
  PersonalCategoryItemsCubit _cubitFor(PersonalCategoryType type) {
    return _cubits.putIfAbsent(
      type,
      () => PersonalCategoryItemsCubit(
        LibraryRemoteDataSourceImpl(ApiService()),
        categoryId: widget.category.id,
        type: type,
      )..load(),
    );
  }

  @override
  void dispose() {
    for (final cubit in _cubits.values) {
      cubit.close();
    }
    super.dispose();
  }

  Future<void> _addItems() async {
    final type = _types[_tabIndex];
    final cubit = _cubitFor(type);
    final ids = await showAddToCategorySheet(
      context,
      categoryName: widget.category.name,
      type: type,
      existingIds: {for (final item in cubit.state.items) item.id},
    );
    if (ids == null || ids.isEmpty) return;
    if (await cubit.addItems(ids)) {
      AppNavigator.showSuccessSnackBar(AppStrings.categoryItemsAdded.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = [for (final type in _types) _tabTitleKey(type).tr()];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: widget.category.name),
      floatingActionButton: !_itemEditingEnabled
          ? null
          : FloatingActionButton(
              onPressed: _addItems,
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 30),
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
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  for (var i = 0; i < _types.length; i++)
                    (i == _tabIndex || _cubits.containsKey(_types[i]))
                        ? BlocProvider.value(
                            value: _cubitFor(_types[i]),
                            child: _CategoryItemsView(type: _types[i]),
                          )
                        : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _tabTitleKey(PersonalCategoryType type) {
  switch (type) {
    case PersonalCategoryType.book:
      return AppStrings.libraryBooks;
    case PersonalCategoryType.issue:
      return AppStrings.libraryMagazineIssuesTab;
    case PersonalCategoryType.article:
      return AppStrings.libraryMagazineArticlesTab;
  }
}

String _emptyTitleKey(PersonalCategoryType type) {
  switch (type) {
    case PersonalCategoryType.book:
      return AppStrings.categoryNoBookTitle;
    case PersonalCategoryType.issue:
      return AppStrings.categoryNoIssueTitle;
    case PersonalCategoryType.article:
      return AppStrings.categoryNoArticleTitle;
  }
}

String _emptyActionKey(PersonalCategoryType type) {
  switch (type) {
    case PersonalCategoryType.book:
      return AppStrings.categoryAddNewBook;
    case PersonalCategoryType.issue:
      return AppStrings.categoryAddNewIssue;
    case PersonalCategoryType.article:
      return AppStrings.categoryAddNewArticle;
  }
}

class _CategoryItemsView extends StatefulWidget {
  final PersonalCategoryType type;

  const _CategoryItemsView({required this.type});

  @override
  State<_CategoryItemsView> createState() => _CategoryItemsViewState();
}

class _CategoryItemsViewState extends State<_CategoryItemsView> {
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
      context.read<PersonalCategoryItemsCubit>().loadMore();
    }
  }

  /// Owned books open in the reader; anything else opens its details.
  void _open(PersonalCategoryItem item) {
    if (item.id.isEmpty) return;
    switch (item.type) {
      case PersonalCategoryType.book:
        final readerBook = LibraryBooksCubit.readerBookOf(item.book!);
        if (readerBook != null) {
          ReaderScreen.open(readerBook);
        } else {
          AppNavigator.push(BookScreen(bookId: item.id));
        }
        break;
      case PersonalCategoryType.issue:
        AppNavigator.push(IssueDetailsScreen(issueId: item.id));
        break;
      case PersonalCategoryType.article:
        final article = item.article!;
        final url = article.url;
        AppNavigator.push(
          (url != null && url.isNotEmpty)
              ? WebViewScreen(url: url, title: article.title)
              : ArticleScreen(articleId: item.id),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PersonalCategoryItemsCubit>();

    return BlocBuilder<PersonalCategoryItemsCubit, PersonalCategoryItemsState>(
      builder: (context, state) {
        switch (state.status) {
          case PersonalCategoryItemsStatus.initial:
          case PersonalCategoryItemsStatus.loading:
            return const LoadingIndicator();

          case PersonalCategoryItemsStatus.failure:
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

          case PersonalCategoryItemsStatus.empty:
            return LibraryRefreshable(
              onRefresh: cubit.refresh,
              child: EmptyStateWidget(
                image: AppImages.noData,
                message: _emptyTitleKey(widget.type).tr(),
                message2: _itemEditingEnabled
                    ? _emptyActionKey(widget.type).tr()
                    : null,
              ),
            );

          case PersonalCategoryItemsStatus.success:
          case PersonalCategoryItemsStatus.loadingMore:
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: cubit.refresh,
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
                    sliver: _buildItems(state.items),
                  ),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingLarge,
                        ),
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
                  // Room for the FAB over the last row.
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
                ],
              ),
            );
        }
      },
    );
  }

  Future<void> _remove(PersonalCategoryItem item) async {
    final removed = await context.read<PersonalCategoryItemsCubit>().removeItem(
      item.id,
    );
    if (removed) {
      AppNavigator.showSuccessSnackBar(AppStrings.categoryItemRemoved.tr());
    }
  }

  Widget _buildItems(List<PersonalCategoryItem> items) {
    if (widget.type == PersonalCategoryType.article) {
      return SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppDimensions.paddingSmall),
        itemBuilder: (_, i) => LibraryArticleCard(
          article: items[i].article!,
          onTap: () => _open(items[i]),
          onDelete: _itemEditingEnabled ? () => _remove(items[i]) : null,
        ),
      );
    }

    final isBook = widget.type == PersonalCategoryType.book;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingMedium,
        mainAxisSpacing: AppDimensions.paddingMedium,
        childAspectRatio: isBook ? 0.54 : 0.72,
      ),
      delegate: SliverChildBuilderDelegate((_, i) {
        final item = items[i];
        if (!isBook) {
          return LibraryIssueCard(
            issue: item.issue!,
            onTap: () => _open(item),
            onDelete: _itemEditingEnabled ? () => _remove(item) : null,
          );
        }
        final card = LibraryBookCard(
          book: item.book!,
          onTap: () => _open(item),
        );
        if (!_itemEditingEnabled) return card;
        // LibraryBookCard doesn't render its own delete badge, so overlay one.
        return Stack(
          children: [
            card,
            PositionedDirectional(
              top: 6,
              end: 6,
              child: LibraryDeleteBadge(onTap: () => _remove(item)),
            ),
          ],
        );
      }, childCount: items.length),
    );
  }
}
