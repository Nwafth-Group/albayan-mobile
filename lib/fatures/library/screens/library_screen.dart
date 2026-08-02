// ============================================
// FILE: lib/fatures/library/screens/library_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.libraryTitle.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: EmptyState(
        icon: Icons.menu_book_outlined,
        title: AppStrings.libraryEmptyTitle.tr(),
        subtitle: AppStrings.libraryEmptySubtitle.tr(),
      ),
    );
  }
}
