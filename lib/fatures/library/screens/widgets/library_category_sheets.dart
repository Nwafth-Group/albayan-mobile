// ============================================
// FILE: lib/fatures/library/screens/widgets/library_category_sheets.dart
// ============================================
//
// Bottom sheets for personal categories: "Add New Category" (name field),
// "Add Book to {category}" and the "Choose from Your Library" picker.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/api_client.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/loading_widget.dart';
import '../../data/datasource/library_remote_data_source.dart';
import '../../data/models/personal_category_model.dart';
import '../cubit/library_item_picker_cubit.dart';
import 'library_article_card.dart';
import 'library_book_card.dart';
import 'library_issue_card.dart';

/// Shows the "Add New Category" sheet. Returns the trimmed name, or null if
/// dismissed / cancelled.
Future<String?> showAddCategorySheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (_) => const _AddCategorySheet(),
  );
}

/// Shows "Add Book to {categoryName}" and, once its field is tapped, the
/// "Choose from Your Library" picker. Returns the picked ids, or null.
Future<List<String>?> showAddToCategorySheet(
  BuildContext context, {
  required String categoryName,
  required PersonalCategoryType type,
  Set<String> existingIds = const {},
}) async {
  final choose = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (_) => _AddToCategorySheet(categoryName: categoryName, type: type),
  );
  if (choose != true || !context.mounted) return null;

  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (_) => BlocProvider(
      create: (_) => LibraryItemPickerCubit(
        LibraryRemoteDataSourceImpl(ApiService()),
        type: type,
      )..load(),
      child: _LibraryItemPickerSheet(type: type, existingIds: existingIds),
    ),
  );
}

String _addToKey(PersonalCategoryType type) {
  switch (type) {
    case PersonalCategoryType.book:
      return AppStrings.categoryAddBookTo;
    case PersonalCategoryType.issue:
      return AppStrings.categoryAddIssueTo;
    case PersonalCategoryType.article:
      return AppStrings.categoryAddArticleTo;
  }
}

/// White rounded sheet with a grabber and a centered title.
class _SheetFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final bool expand;

  const _SheetFrame({
    required this.title,
    required this.child,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeLarge,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        if (expand) Expanded(child: child) else child,
      ],
    );

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: body,
      ),
    );
  }
}

/// Cancel (outlined) + primary action, side by side.
class _SheetActions extends StatelessWidget {
  final String primaryText;
  final VoidCallback? onPrimary;

  const _SheetActions({required this.primaryText, this.onPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: CustomButton(
              text: AppStrings.cancel.tr(),
              isOutlined: true,
              textColor: AppColors.primary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: CustomButton(text: primaryText, onPressed: onPrimary),
          ),
        ),
      ],
    );
  }
}

/// Tinted, primary-bordered field used by both "add" sheets.
BoxDecoration _fieldDecoration() => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  border: Border.all(color: AppColors.primary),
);

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: AppStrings.libraryAddNewCategory.tr(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _fieldDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppStrings.libraryCategoryNameHint.tr(),
                      hintStyle: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.create_new_folder_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          _SheetActions(
            primaryText: AppStrings.librarySave.tr(),
            onPrimary: _controller.text.trim().isEmpty ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _AddToCategorySheet extends StatelessWidget {
  final String categoryName;
  final PersonalCategoryType type;

  const _AddToCategorySheet({required this.categoryName, required this.type});

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: _addToKey(type).tr(namedArgs: {'name': categoryName}),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(true),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: _fieldDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.categoryChooseFromLibrary.tr(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.folder_open_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryItemPickerSheet extends StatefulWidget {
  final PersonalCategoryType type;
  final Set<String> existingIds;

  const _LibraryItemPickerSheet({
    required this.type,
    required this.existingIds,
  });

  @override
  State<_LibraryItemPickerSheet> createState() =>
      _LibraryItemPickerSheetState();
}

class _LibraryItemPickerSheetState extends State<_LibraryItemPickerSheet> {
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
      context.read<LibraryItemPickerCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: _SheetFrame(
        title: AppStrings.categoryChooseFromLibrary.tr(),
        expand: true,
        child: BlocBuilder<LibraryItemPickerCubit, LibraryItemPickerState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(child: _buildBody(context, state)),
                const Divider(height: 1, color: AppColors.surfaceVariant),
                const SizedBox(height: AppDimensions.paddingMedium),
                _SheetActions(
                  primaryText: AppStrings.librarySave.tr(),
                  onPrimary: state.selectedIds.isEmpty
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pop(state.selectedIds.toList()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LibraryItemPickerState state) {
    final cubit = context.read<LibraryItemPickerCubit>();
    switch (state.status) {
      case LibraryItemPickerStatus.initial:
      case LibraryItemPickerStatus.loading:
        return const LoadingIndicator();

      case LibraryItemPickerStatus.failure:
        return EmptyStateWidget(
          image: AppImages.noData,
          message: AppStrings.somethingWentWrong.tr(),
          message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
          actionText: AppStrings.retry.tr(),
          onAction: cubit.load,
        );

      case LibraryItemPickerStatus.empty:
        return EmptyStateWidget(
          image: AppImages.noData,
          message: AppStrings.libraryNoItems.tr(),
        );

      case LibraryItemPickerStatus.success:
      case LibraryItemPickerStatus.loadingMore:
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildItems(state),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
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
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.paddingMedium),
            ),
          ],
        );
    }
  }

  Widget _buildItems(LibraryItemPickerState state) {
    final cubit = context.read<LibraryItemPickerCubit>();

    Widget tile(PersonalCategoryItem item) {
      // Items already in the category show as checked and can't be toggled.
      final locked = widget.existingIds.contains(item.id);
      final selected = locked || state.selectedIds.contains(item.id);
      final onTap = locked ? null : () => cubit.toggle(item.id);
      final Widget card;
      switch (item.type) {
        case PersonalCategoryType.book:
          card = LibraryBookCard(book: item.book!, onTap: onTap);
          break;
        case PersonalCategoryType.issue:
          card = LibraryIssueCard(issue: item.issue!, onTap: onTap);
          break;
        case PersonalCategoryType.article:
          card = LibraryArticleCard(article: item.article!, onTap: onTap);
          break;
      }
      return Opacity(
        opacity: locked ? 0.6 : 1,
        child: Stack(
          children: [
            card,
            PositionedDirectional(
              top: 6,
              end: 6,
              child: IgnorePointer(child: _SelectMark(selected: selected)),
            ),
          ],
        ),
      );
    }

    if (widget.type == PersonalCategoryType.article) {
      return SliverList.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppDimensions.paddingSmall),
        itemBuilder: (_, i) => tile(state.items[i]),
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
      delegate: SliverChildBuilderDelegate(
        (_, i) => tile(state.items[i]),
        childCount: state.items.length,
      ),
    );
  }
}

/// Round check mark in a picker tile's corner.
class _SelectMark extends StatelessWidget {
  final bool selected;

  const _SelectMark({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.white : AppColors.textLight,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: AppColors.white)
          : null,
    );
  }
}
