
// ============================================
// FILE: lib/fatures/library/screens/widgets/library_delete_badge.dart
// ============================================

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// Small white circular trash button overlaid on a library item's cover
/// image, used to remove that item from the (currently mocked) library.
class LibraryDeleteBadge extends StatelessWidget {
  final VoidCallback? onTap;
  const LibraryDeleteBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.delete_outline,
          size: 15,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
