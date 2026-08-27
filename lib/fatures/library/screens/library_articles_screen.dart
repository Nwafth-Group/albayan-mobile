
// ============================================
// FILE: lib/fatures/library/screens/library_articles_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/library_mock_data.dart';
import '../data/models/library_article_model.dart';
import 'widgets/library_article_card.dart';

class LibraryArticlesScreen extends StatefulWidget {
  const LibraryArticlesScreen({super.key});

  @override
  State<LibraryArticlesScreen> createState() => _LibraryArticlesScreenState();
}

class _LibraryArticlesScreenState extends State<LibraryArticlesScreen> {
  late final List<LibraryArticleModel> _articles = mockLibraryArticles();

  void _delete(LibraryArticleModel article) {
    setState(() => _articles.removeWhere((a) => a.id == article.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryMagazineArticlesTab.tr()),
      body: SafeArea(
        child: _articles.isEmpty
            ? EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.libraryNoItems.tr(),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                ),
                itemCount: _articles.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.paddingSmall),
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return LibraryArticleCard(
                    article: article,
                    onDelete: () => _delete(article),
                  );
                },
              ),
      ),
    );
  }
}
