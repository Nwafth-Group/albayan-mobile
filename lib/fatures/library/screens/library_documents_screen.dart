
// ============================================
// FILE: lib/fatures/library/screens/library_documents_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/library_mock_data.dart';
import '../data/models/library_book_model.dart';
import 'widgets/library_book_card.dart';
import 'widgets/library_upload_sheet.dart';

class LibraryDocumentsScreen extends StatefulWidget {
  const LibraryDocumentsScreen({super.key});

  @override
  State<LibraryDocumentsScreen> createState() =>
      _LibraryDocumentsScreenState();
}

class _LibraryDocumentsScreenState extends State<LibraryDocumentsScreen> {
  late final List<LibraryBookModel> _documents = mockLibraryDocuments();

  void _delete(LibraryBookModel doc) {
    setState(() => _documents.removeWhere((d) => d.id == doc.id));
  }

  Future<void> _addDocuments() async {
    final picked = await showLibraryUploadSheet(context);
    if (picked != true) return;
    // TODO: wire up a real file picker + upload endpoint once available.
    // For now, "choosing" a file simulates adding the saved mock books so
    // the populated-grid state can be reviewed.
    setState(() => _documents.addAll(mockLibraryBooks()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryMyDocuments.tr()),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDocuments,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: SafeArea(
        child: _documents.isEmpty
            ? EmptyStateWidget(
                icon: Icons.folder_copy_outlined,
                message: AppStrings.libraryNoDocuments.tr(),
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
                  childAspectRatio: 0.54,
                ),
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final doc = _documents[index];
                  return LibraryBookCard(
                    book: doc,
                    onDelete: () => _delete(doc),
                  );
                },
              ),
      ),
    );
  }
}
