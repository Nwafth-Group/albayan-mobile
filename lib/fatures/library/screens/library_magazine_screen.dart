
// ============================================
// FILE: lib/fatures/library/screens/library_magazine_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../data/library_mock_data.dart';
import 'library_articles_screen.dart';
import 'library_issues_screen.dart';
import 'widgets/library_section_card.dart';
import '../data/models/library_section_model.dart';

class LibraryMagazineScreen extends StatelessWidget {
  const LibraryMagazineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final issuesCount = mockLibraryIssues().length;
    final articlesCount = mockLibraryArticles().length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryAlbayanMagazine.tr()),
      body: SafeArea(
        child: GridView.count(
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
                count: issuesCount,
              ),
              color: AppColors.surfaceVariant,
              onTap: () => AppNavigator.push(const LibraryIssuesScreen()),
            ),
            LibrarySectionCard(
              section: LibrarySectionModel(
                type: LibrarySectionType.magazine,
                titleKey: AppStrings.libraryMagazineArticlesTab,
                countKey: AppStrings.libraryArticlesCount,
                count: articlesCount,
              ),
              color: AppColors.surfaceDark,
              onTap: () => AppNavigator.push(const LibraryArticlesScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
