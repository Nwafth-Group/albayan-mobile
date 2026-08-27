// ============================================
// FILE: lib/fatures/library/screens/library_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/library_mock_data.dart';
import '../data/models/library_section_model.dart';
import 'library_books_screen.dart';
import 'library_documents_screen.dart';
import 'library_magazine_screen.dart';
import 'widgets/library_section_card.dart';
import 'widgets/library_tabs.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // TODO: replace with a real cubit + datasource once a library endpoint
  // exists. For now the screen renders straight from mock data.
  late final List<LibrarySectionModel> _sections = mockLibrarySections();
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
        return _buildSectionsGrid();
      case 1:
        return EmptyStateWidget(
          image: AppImages.noData,
          message: AppStrings.libraryNoCategories.tr(),
        );
      default:
        return EmptyStateWidget(
          image: AppImages.noData,
          message: AppStrings.libraryNoFavorites.tr(),
        );
    }
  }

  Widget _buildSectionsGrid() {
    if (_sections.isEmpty) {
      return EmptyStateWidget(
        image: AppImages.noData,
        message: AppStrings.libraryEmptyTitle.tr(),
        message2: AppStrings.libraryEmptySubtitle.tr(),
      );
    }

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
      itemCount: _sections.length,
      itemBuilder: (context, index) {
        return LibrarySectionCard(
          section: _sections[index],
          color: index.isEven
              ? AppColors.surfaceVariant
              : AppColors.surfaceDark,
          onTap: () => _openSection(_sections[index]),
        );
      },
    );
  }

  void _openSection(LibrarySectionModel section) {
    switch (section.type) {
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
