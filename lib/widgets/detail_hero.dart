// ============================================
// FILE: lib/widgets/detail_hero.dart
// ============================================
//
// The header shared by the issue and article details pages: the cover,
// blurred, as the background; the sharp cover centered on top; the title
// (and an optional subtitle line) below it in white.

import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_navigator.dart';
import '../utils/constants.dart';

class DetailHero extends StatelessWidget {
  final String? coverUrl;
  final String title;
  final String? subtitle;

  /// Drawn at the top, e.g. a [DetailTopBar]. When null, a toolbar-height
  /// gap is left instead — for a page whose app bar draws that row itself.
  final Widget? topBar;

  /// Space kept clear under the text, e.g. for a sheet overlapping the
  /// bottom of the hero.
  final double bottomSpacing;

  const DetailHero({
    super.key,
    required this.coverUrl,
    required this.title,
    this.subtitle,
    this.topBar,
    this.bottomSpacing = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DetailBlurredCover(url: coverUrl),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.25),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.35),
              ],
              stops: const [0, 0.4, 1],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              topBar ?? const SizedBox(height: kToolbarHeight),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AspectRatio(
                      aspectRatio: 0.84,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _SharpCover(url: coverUrl),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: Colors.white),
                  ),
                ),
              ],
              SizedBox(height: bottomSpacing),
            ],
          ),
        ),
      ],
    );
  }
}

/// Back arrow + page title on the start side, [actions] on the end side,
/// all in white — the top row of a [DetailHero].
class DetailTopBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const DetailTopBar({super.key, required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => AppNavigator.pop(),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          for (final action in actions)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: action,
            ),
          const SizedBox(width: AppDimensions.paddingMedium),
        ],
      ),
    );
  }
}

/// One of the round white header actions (crown / book / heart). The icon
/// assets already include their white circle.
class DetailCircleAction extends StatelessWidget {
  final String asset;
  final VoidCallback? onTap;

  const DetailCircleAction({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Image.asset(asset, width: 28, height: 28, fit: BoxFit.contain),
    );
  }
}

/// The header heart: the outlined-heart asset when not a favorite, the same
/// cream circle with a filled maroon heart when it is.
class DetailFavoriteAction extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const DetailFavoriteAction({
    super.key,
    required this.isFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: isFavorite
            ? Container(
                key: const ValueKey('favorite'),
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  // Matches the circle baked into the `favorate` asset.
                  color: AppColors.cardColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 17,
                  color: AppColors.primary,
                ),
              )
            : Image.asset(
                AppImages.favorate,
                key: const ValueKey('not-favorite'),
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}

class DetailBlurredCover extends StatelessWidget {
  final String? url;
  const DetailBlurredCover({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(color: const Color(0xFF2A2A2A));
    if (url == null || url!.isEmpty) return fallback;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
          ),
        ],
      ),
    );
  }
}

class _SharpCover extends StatelessWidget {
  final String? url;
  const _SharpCover({this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.menu_book_outlined,
        color: AppColors.textLight,
        size: 40,
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
