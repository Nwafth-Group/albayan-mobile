
// ============================================
// FILE: lib/fatures/library/screens/library_issues_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/library_mock_data.dart';
import '../data/models/library_issue_model.dart';
import 'widgets/library_issue_card.dart';

class LibraryIssuesScreen extends StatefulWidget {
  const LibraryIssuesScreen({super.key});

  @override
  State<LibraryIssuesScreen> createState() => _LibraryIssuesScreenState();
}

class _LibraryIssuesScreenState extends State<LibraryIssuesScreen> {
  late final List<LibraryIssueModel> _issues = mockLibraryIssues();

  void _delete(LibraryIssueModel issue) {
    setState(() => _issues.removeWhere((i) => i.id == issue.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryMagazineIssuesTab.tr()),
      body: SafeArea(
        child: _issues.isEmpty
            ? EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.libraryNoItems.tr(),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.paddingMedium,
                  mainAxisSpacing: AppDimensions.paddingMedium,
                  childAspectRatio: 0.72,
                ),
                itemCount: _issues.length,
                itemBuilder: (context, index) {
                  final issue = _issues[index];
                  return LibraryIssueCard(
                    issue: issue,
                    onDelete: () => _delete(issue),
                  );
                },
              ),
      ),
    );
  }
}
