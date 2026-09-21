// ============================================
// FILE: lib/fatures/library/screens/personal_categories_screen.dart
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
import '../data/models/personal_category_model.dart';
import 'cubit/personal_categories_cubit.dart';

String personalCategoryTitleKey(PersonalCategoryType type) {
  switch (type) {
    case PersonalCategoryType.book:
      return AppStrings.libraryBooks;
    case PersonalCategoryType.issue:
      return AppStrings.libraryMagazineIssuesTab;
    case PersonalCategoryType.article:
      return AppStrings.libraryMagazineArticlesTab;
  }
}

/// Lists the reader's personal categories for one content [type].
class PersonalCategoriesScreen extends StatelessWidget {
  final PersonalCategoryType type;

  const PersonalCategoriesScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalCategoriesCubit(
        LibraryRemoteDataSourceImpl(ApiService()),
        type: type,
      )..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: personalCategoryTitleKey(type).tr()),
        body: SafeArea(
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
                    onAction: () =>
                        context.read<PersonalCategoriesCubit>().load(),
                  );
                case PersonalCategoriesStatus.empty:
                  return EmptyStateWidget(
                    image: AppImages.noData,
                    message: AppStrings.libraryNoCategories.tr(),
                  );
                case PersonalCategoriesStatus.success:
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        context.read<PersonalCategoriesCubit>().load(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      itemCount: state.categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppDimensions.paddingSmall),
                      itemBuilder: (_, i) =>
                          _CategoryTile(category: state.categories[i]),
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final PersonalCategoryModel category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              AppStrings.libraryItemsCount
                  .tr(namedArgs: {'count': '${category.itemsCount}'}),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
