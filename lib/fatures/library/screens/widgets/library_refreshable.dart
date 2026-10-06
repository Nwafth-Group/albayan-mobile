// ============================================
// FILE: lib/fatures/library/screens/widgets/library_refreshable.dart
// ============================================

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// Makes a non-scrolling child (empty / error state) pull-to-refreshable:
/// it fills the viewport inside an always-scrollable view so the
/// [RefreshIndicator] can be dragged even when there's nothing to scroll.
class LibraryRefreshable extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const LibraryRefreshable({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
