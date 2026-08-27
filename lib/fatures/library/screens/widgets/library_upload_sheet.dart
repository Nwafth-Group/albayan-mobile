
// ============================================
// FILE: lib/fatures/library/screens/widgets/library_upload_sheet.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// Shows the "Add Items to My Documents" sheet. Returns `true` if the user
/// tapped the file-choice row, `null`/`false` if dismissed.
Future<bool?> showLibraryUploadSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LibraryUploadSheet(),
  );
}

class _LibraryUploadSheet extends StatelessWidget {
  const _LibraryUploadSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingLarge,
        right: AppDimensions.paddingLarge,
        top: AppDimensions.paddingMedium,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingLarge,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Center(
            child: Text(
              AppStrings.libraryAddDocumentsTitle.tr(),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          InkWell(
            onTap: () => Navigator.of(context).pop(true),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.libraryChooseFromPhone.tr(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      color: AppColors.textLight,
                    ),
                  ),
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
