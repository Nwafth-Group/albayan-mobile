// ============================================
// FILE: lib/widgets/promo_banner.dart
// ============================================
//
// The promo banner (shown on the home page, the corners list, a corner's
// page, the issues list, and the issue/article details pages). It renders
// only the banner image from the API — the image itself is the design.
//
// [AdPromoBanner] fills it from the home `ad_banner` section, fetched once
// per app session and shared by every screen that shows it.

import 'package:flutter/material.dart';

import '../fatures/articles/screens/article_screen.dart';
import '../fatures/books/screens/book_screen.dart';
import '../fatures/corners/screens/corner_screen.dart';
import '../fatures/home/data/datasource/home_remote_data_source.dart';
import '../fatures/home/data/models/home_section_model.dart';
import '../fatures/issues/screens/issue_details_screen.dart';
import '../utils/api_client.dart';
import '../utils/app_navigator.dart';
import '../utils/constants.dart';

/// Opens whatever a home `ad_banner` item points at.
void openHomeBannerItem(HomeBannerItem item) {
  final id = item.firstItemId;
  if (id == null || id.isEmpty) return;
  switch (item.itemType) {
    case 'books':
      AppNavigator.push(BookScreen(bookId: id));
      break;
    case 'corners':
      AppNavigator.push(CornerScreen(cornerId: id));
      break;
    case 'articles':
      AppNavigator.push(ArticleScreen(articleId: id));
      break;
    case 'issues':
      AppNavigator.push(IssueDetailsScreen(issueId: id));
      break;
    default:
      // `general` banners only carry an external `link_url` — opening it
      // would need a url_launcher dependency this project doesn't have yet.
      break;
  }
}

/// A banner is just its image — the artwork from the API already contains
/// the whole design (title, text, CTA, covers), so nothing is drawn on top.
class PromoBanner extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const PromoBanner({super.key, this.imageUrl, this.onTap});

  static const double height = 176;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(color: AppColors.surfaceVariant);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? placeholder
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

/// [PromoBanner] filled from the home `ad_banner` section: the first
/// banner's image and link.
/// Renders nothing if there are no banners (or the request failed).
class AdPromoBanner extends StatefulWidget {
  final EdgeInsetsGeometry padding;

  const AdPromoBanner({super.key, this.padding = EdgeInsets.zero});

  static Future<List<HomeBannerItem>>? _cache;

  static Future<List<HomeBannerItem>> _banners() => _cache ??= _fetch();

  static Future<List<HomeBannerItem>> _fetch() async {
    try {
      final section = await HomeRemoteDataSourceImpl(
        ApiService(),
      ).getSection(ApiConstants.homeSectionBanners);
      return section.banners;
    } catch (_) {
      _cache = null; // let the next banner on screen retry
      return const [];
    }
  }

  /// Forget the cached banners so the next [AdPromoBanner] re-fetches —
  /// e.g. on the home page's pull-to-refresh.
  static void invalidate() => _cache = null;

  @override
  State<AdPromoBanner> createState() => _AdPromoBannerState();
}

class _AdPromoBannerState extends State<AdPromoBanner> {
  late final Future<List<HomeBannerItem>> _future = AdPromoBanner._banners();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HomeBannerItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Same-size placeholder so content doesn't jump when it loads.
          return Padding(
            padding: widget.padding,
            child: Container(
              height: PromoBanner.height,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }

        final banners = snapshot.data ?? const <HomeBannerItem>[];
        if (banners.isEmpty) return const SizedBox.shrink();

        final first = banners.first;
        return Padding(
          padding: widget.padding,
          child: PromoBanner(
            imageUrl: first.image,
            onTap: () => openHomeBannerItem(first),
          ),
        );
      },
    );
  }
}
