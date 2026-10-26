// ============================================
// FILE: lib/fatures/library/screens/library_documents_screen.dart
// ============================================

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../reader/data/models/reader_models.dart';
import '../../reader/screens/reader_screen.dart';
import '../data/datasource/library_documents_remote_data_source.dart';
import '../data/models/personal_document_model.dart';
import 'cubit/library_documents_cubit.dart';
import 'widgets/library_document_card.dart';
import 'widgets/library_refreshable.dart';
import 'widgets/library_upload_sheet.dart';

class LibraryDocumentsScreen extends StatelessWidget {
  const LibraryDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LibraryDocumentsCubit(
        LibraryDocumentsRemoteDataSourceImpl(ApiService()),
      )..load(),
      child: const _LibraryDocumentsView(),
    );
  }
}

class _LibraryDocumentsView extends StatefulWidget {
  const _LibraryDocumentsView();

  @override
  State<_LibraryDocumentsView> createState() => _LibraryDocumentsViewState();
}

class _LibraryDocumentsViewState extends State<_LibraryDocumentsView> {
  Future<void> _openReader(PersonalDocumentModel document) async {
    final cubit = context.read<LibraryDocumentsCubit>();
    await ReaderScreen.open(
      ReaderBook(
        id: document.id,
        title: document.title,
        pdfUrl: document.file.url,
        kind: ReaderContentKind.document,
      ),
    );
    // The reader syncs progress to the server itself; reload so this
    // document's progress bar reflects it.
    if (mounted) cubit.load();
  }

  Future<void> _addDocuments() async {
    final picked = await showLibraryUploadSheet(context);
    if (picked != true || !mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    final fileName = result!.files.single.name;
    final defaultTitle = fileName.replaceAll(
      RegExp(r'\.pdf$', caseSensitive: false),
      '',
    );
    final title = await _askTitle(context, defaultTitle);
    if (title == null || title.trim().isEmpty || !mounted) return;

    final ok = await context.read<LibraryDocumentsCubit>().upload(
      File(path),
      title.trim(),
    );
    if (ok && mounted) {
      AppNavigator.showSuccessSnackBar(
        AppStrings.libraryDocumentUploaded.tr(),
      );
    }
  }

  Future<String?> _askTitle(BuildContext context, String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.libraryDocumentTitleLabel.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.libraryDocumentTitleHint.tr(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: Text(AppStrings.libraryUpload.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(PersonalDocumentModel document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.libraryDeleteDocumentTitle.tr()),
        content: Text(AppStrings.libraryDeleteDocumentMessage.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<LibraryDocumentsCubit>().delete(document.id);
    if (mounted) {
      AppNavigator.showSuccessSnackBar(
        AppStrings.libraryDocumentDeleted.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.libraryMyDocuments.tr()),
      floatingActionButton: BlocBuilder<LibraryDocumentsCubit,
          LibraryDocumentsState>(
        builder: (context, state) => FloatingActionButton(
          onPressed: state.isUploading ? null : _addDocuments,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: state.isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Icon(Icons.add, color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<LibraryDocumentsCubit, LibraryDocumentsState>(
          builder: (context, state) {
            switch (state.status) {
              case LibraryDocumentsStatus.initial:
              case LibraryDocumentsStatus.loading:
                return const LoadingIndicator();

              case LibraryDocumentsStatus.failure:
                return LibraryRefreshable(
                  onRefresh: () =>
                      context.read<LibraryDocumentsCubit>().load(),
                  child: EmptyStateWidget(
                    icon: Icons.wifi_off_rounded,
                    message: AppStrings.somethingWentWrong.tr(),
                    message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                    actionText: AppStrings.retry.tr(),
                    onAction: () =>
                        context.read<LibraryDocumentsCubit>().load(),
                  ),
                );

              case LibraryDocumentsStatus.empty:
                return LibraryRefreshable(
                  onRefresh: () =>
                      context.read<LibraryDocumentsCubit>().load(),
                  child: EmptyStateWidget(
                    icon: Icons.folder_copy_outlined,
                    message: AppStrings.libraryNoDocuments.tr(),
                  ),
                );

              case LibraryDocumentsStatus.success:
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<LibraryDocumentsCubit>().load(),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingLarge,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppDimensions.paddingMedium,
                      mainAxisSpacing: AppDimensions.paddingMedium,
                      childAspectRatio: 0.54,
                    ),
                    itemCount: state.documents.length,
                    itemBuilder: (context, index) {
                      final doc = state.documents[index];
                      return LibraryDocumentCard(
                        document: doc,
                        isDeleting: state.deletingIds.contains(doc.id),
                        onTap: () => _openReader(doc),
                        onDelete: () => _confirmDelete(doc),
                        onDownload: () => context
                            .read<LibraryDocumentsCubit>()
                            .download(doc),
                      );
                    },
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
