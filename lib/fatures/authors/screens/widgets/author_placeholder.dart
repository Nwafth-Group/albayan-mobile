// ============================================
// FILE: lib/fatures/authors/screens/widgets/author_placeholder.dart
// ============================================
//
// Stand-ins for an author / writer with no `image`: a cream tile with a
// writer (person + pen) icon (avatars, overview photo) and a full-bleed
// header background.

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../utils/constants.dart';

/// Cream tile with a maroon writer icon — fills whatever box it's given.
class AuthorPlaceholder extends StatelessWidget {
  final double iconSize;

  const AuthorPlaceholder({super.key, this.iconSize = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentPale,
      alignment: Alignment.center,
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedUserEdit01,
        color: AppColors.primary,
        size: iconSize,
      ),
    );
  }
}

/// Author details header background when there's no photo: a warm dark
/// gradient with a ringed writer badge centered above the name.
class AuthorHeaderPlaceholder extends StatelessWidget {
  final Color background;

  const AuthorHeaderPlaceholder({super.key, required this.background});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 0.9,
          colors: [AppColors.primary.withValues(alpha: 0.55), background],
        ),
      ),
      child: Align(
        // Above the name block pinned to the bottom of the header.
        alignment: const Alignment(0, -0.2),
        child: Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: const ClipOval(child: AuthorPlaceholder(iconSize: 46)),
        ),
      ),
    );
  }
}
