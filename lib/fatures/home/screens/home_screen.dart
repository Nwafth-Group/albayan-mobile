import 'dart:async';
import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/data/models/user_model.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/articles/screens/article_screen.dart';
import 'package:albayan/fatures/articles/screens/articles_list_screen.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:albayan/fatures/authors/screens/author_screen.dart';
import 'package:albayan/fatures/authors/screens/authors_list_screen.dart';
import 'package:albayan/fatures/books/screens/book_screen.dart';
import 'package:albayan/fatures/books/screens/books_list_screen.dart';
import 'package:albayan/fatures/corners/screens/corner_screen.dart';
import 'package:albayan/fatures/corners/screens/corners_list_screen.dart';
import 'package:albayan/fatures/issues/screens/issue_details_screen.dart';
import 'package:albayan/fatures/issues/screens/issues_screen.dart';
import 'package:albayan/fatures/notifications/screens/notifications_screen.dart';
import 'package:albayan/fatures/offers/screens/offers_list_screen.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/utils/shared_pref_helper.dart';
import 'package:albayan/widgets/promo_banner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/datasource/home_remote_data_source.dart';
import '../data/models/home_section_model.dart';
import 'cubit/home_cubit.dart';

// ============================================
// DATA MODELS (lightweight, view-only — built from HomeSectionModel below)
// ============================================

class IssueModel {
  final String id;
  final String image;
  final String title;
  final String date;
  final String price;
  IssueModel({
    required this.id,
    required this.image,
    required this.title,
    required this.date,
    required this.price,
  });
}

class ArticleModel {
  final String id;
  final String image;
  final String category;
  final String title;
  final String author;
  final String price;
  final String date;
  final double rating;
  ArticleModel({
    required this.id,
    required this.image,
    required this.category,
    required this.title,
    required this.author,
    required this.price,
    required this.date,
    required this.rating,
  });
}

class AuthorModel {
  final String id;
  final String? image;
  final String name;
  AuthorModel({required this.id, this.image, required this.name});
}

class BookModel {
  final String id;
  final String image;
  final String title;
  final String author;
  final String price;
  final double rating;
  BookModel({
    required this.id,
    required this.image,
    required this.title,
    required this.author,
    required this.price,
    required this.rating,
  });
}

class NewsModel {
  final String id;
  final String image;
  final String title;
  final String? description;
  final String timeAgo;
  NewsModel({
    required this.id,
    required this.image,
    required this.title,
    this.description,
    required this.timeAgo,
  });
}

// ============================================
// Small formatting helpers shared by the mappers below
// ============================================

String _formatDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('MMM d, yyyy').format(date);
}

String _priceLabel(num price, {required bool isFree}) {
  if (isFree || price <= 0) return AppStrings.free.tr();
  return '${price.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}';
}

/// Loads a cover/photo that may be a real network URL (the API) or a local
/// asset path (leftover mock data for the sections with no backing API yet),
/// falling back to a placeholder icon either way.
Widget _homeImage(
  String? path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  IconData fallbackIcon = Icons.image_outlined,
}) {
  Widget placeholder() => Container(
    width: width,
    height: height,
    color: AppColors.surfaceVariant,
    child: Icon(fallbackIcon, color: AppColors.textLight, size: 28),
  );

  if (path == null || path.isEmpty) return placeholder();

  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }

  return Image.asset(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => placeholder(),
  );
}

/// White rounded card with a soft shadow, used by the article and news rows.
final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ],
);

// ============================================
// HOME SCREEN
// ============================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Profile ────────────────────────────────────────────────────
  UserModel? _user;
  late final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSub;

  // ── Home sections ──────────────────────────────────────────────
  late final HomeCubit _homeCubit;
  HomeState _homeState = const HomeState();
  StreamSubscription<HomeState>? _homeSub;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(AuthRemoteDataSource(ApiService()));

    // Show cached profile data instantly, then refresh from the API.
    _user = SharedPrefHelper.getUser();
    _loadProfile();

    // Home sections: fetched once on open (also re-runs naturally after
    // login, since login navigates via `pushAndRemoveUntil(MainScreen())`,
    // which builds a brand-new HomeScreen/HomeCubit) and again on
    // pull-to-refresh via `_onRefresh`.
    _homeCubit = HomeCubit(HomeRemoteDataSourceImpl(ApiService()));
    _homeState = _homeCubit.state;
    _homeSub = _homeCubit.stream.listen((state) {
      if (mounted) setState(() => _homeState = state);
    });
    _homeCubit.load();
  }

  void _loadProfile() {
    if (!SharedPrefHelper.isLoggedIn()) return;

    _authSub = _authCubit.stream.listen((state) {
      if (!mounted) return;
      if (state is ProfileLoaded) {
        setState(() => _user = state.user);
      }
      // On ProfileError we silently keep whatever cached data we had —
      // the home screen shouldn't block or show an error banner over this.
    });

    _authCubit.getProfile();
  }

  Future<void> _onRefresh() {
    // The promo banner on other screens caches the same banners section.
    AdPromoBanner.invalidate();
    return _homeCubit.refresh();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authCubit.close();
    _homeSub?.cancel();
    _homeCubit.close();
    super.dispose();
  }

  // ── Mappers: HomeSectionModel items → the view models above ─────
  List<AuthorModel> get _authorModels {
    final authors =
        _homeState.authorsSection?.authors ?? const <HomeAuthorItem>[];
    return authors
        .map((a) => AuthorModel(id: a.id, image: a.image, name: a.name))
        .toList();
  }

  List<IssueModel> get _issueModels {
    final issues = _homeState.issuesSection?.issues ?? const <HomeIssueItem>[];
    return issues
        .map(
          (i) => IssueModel(
            id: i.id,
            image: i.coverImage ?? '',
            title: i.title,
            date: _formatDate(i.publishedAt),
            price: _priceLabel(i.effectivePrice, isFree: i.isFree),
          ),
        )
        .toList();
  }

  List<ArticleModel> get _articleModels {
    final articles =
        _homeState.articlesSection?.articles ?? const <HomeArticleItem>[];
    return articles.map(_articleModelOf).toList();
  }

  ArticleModel _articleModelOf(HomeArticleItem a) {
    final date = _formatDate(a.publishedAt);
    return ArticleModel(
      id: a.id,
      image: a.image ?? '',
      category: date,
      title: a.title,
      author: a.author ?? '',
      price: _priceLabel(a.effectivePrice, isFree: a.isFree),
      date: date,
      rating: a.rate,
    );
  }

  List<BookModel> get _bookModels {
    final books = _homeState.booksSection?.books ?? const <HomeBookItem>[];
    return books
        .map(
          (b) => BookModel(
            // `id` (not `book_id`) is what the book details API expects.
            id: b.id,
            image: b.image ?? '',
            title: b.name,
            author: b.author,
            price: _priceLabel(b.effectivePrice, isFree: b.isFree),
            rating: b.rate,
          ),
        )
        .toList();
  }

  List<NewsModel> get _newsModels {
    final articles =
        _homeState.freshNewsSection?.articles ?? const <HomeArticleItem>[];
    return articles
        .map(
          (a) => NewsModel(
            id: a.id,
            image: a.image ?? '',
            title: a.title,
            description: null, // not returned by this endpoint
            timeAgo: _formatDate(a.publishedAt),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── App Bar ──────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── Featured Banner(s) ───────────────────────────────
              SliverToBoxAdapter(child: _buildFeaturedBanner()),

              // ── Corners ───────────────────────────────────────────
              if ((_homeState.cornersSection?.corners.isNotEmpty ?? false))
                SliverToBoxAdapter(child: _buildCategoryChips()),

              // ── Latest Issues ────────────────────────────────────
              if (_issueModels.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    _homeState.issuesSection?.meta.title ??
                        AppStrings.homeLatestIssues.tr(),
                    () => AppNavigator.push(const IssuesScreen()),
                    showSeeAll:
                        _homeState.issuesSection?.meta.showSeeAll ?? true,
                  ),
                ),
                SliverToBoxAdapter(child: _buildLatestIssues()),
              ],

              // ── Articles ─────────────────────────────────────────
              if (_articleModels.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    _homeState.articlesSection?.meta.title ??
                        AppStrings.articlesTitle.tr(),
                    () => AppNavigator.push(const ArticlesListScreen()),
                    showSeeAll:
                        _homeState.articlesSection?.meta.showSeeAll ?? true,
                  ),
                ),
                SliverToBoxAdapter(child: _buildArticlesList()),
              ],

              // ── Writers & Authors ─────────────────────────────────
              if (_authorModels.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    _homeState.authorsSection?.meta.title ??
                        AppStrings.authorsTitle.tr(),
                    () => AppNavigator.push(const AuthorsListScreen()),
                    showSeeAll:
                        _homeState.authorsSection?.meta.showSeeAll ?? true,
                  ),
                ),
                SliverToBoxAdapter(child: _buildAuthors()),
              ],

              // ── Best Books ───────────────────────────────────────
              if (_bookModels.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    _homeState.booksSection?.meta.title ??
                        AppStrings.homeBestBooks.tr(),
                    () => AppNavigator.push(const BooksListScreen()),
                    showSeeAll:
                        _homeState.booksSection?.meta.showSeeAll ?? true,
                  ),
                ),
                SliverToBoxAdapter(child: _buildBestBooks()),
              ],

              // ── Fresh News ───────────────────────────────────────
              if (_newsModels.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    _homeState.freshNewsSection?.meta.title ??
                        AppStrings.homeFreshNews.tr(),
                    () => AppNavigator.push(const ArticlesListScreen()),
                    showSeeAll:
                        _homeState.freshNewsSection?.meta.showSeeAll ?? true,
                  ),
                ),
                SliverToBoxAdapter(child: _buildFreshNews()),
              ],

              // ── Recommendations (reuses Best Books — no separate API) ─
              if (_bookModels.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    AppStrings.homeRecommendations.tr(),
                    null,
                    showSeeAll: false,
                  ),
                ),
                SliverToBoxAdapter(child: _buildRecommendations()),
              ],

              if (_homeState.status == HomeStatus.loading &&
                  _homeState.sections.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_homeState.status == HomeStatus.failure &&
                  _homeState.sections.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: AppColors.textLight,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _homeState.error ?? AppStrings.somethingWentWrong.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _homeCubit.load,
                            child: Text(AppStrings.retry.tr()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    final isLoggedIn = SharedPrefHelper.isLoggedIn();
    final displayName = _user?.displayName ?? (isLoggedIn
            ? AppStrings.homeReaderName.tr()
            : AppStrings.homeGuestName.tr());
    final profileImage = _user?.profileImage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.surfaceVariant, width: 2),
            ),
            child: ClipOval(
              child: (profileImage != null && profileImage.isNotEmpty)
                  ? Image.network(
                      profileImage,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        AppStrings.homeGreeting.tr(namedArgs: {'name': displayName}),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_user?.haveSubscription == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentPale,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _user?.subscriptionStatus ?? AppStrings.subActive.tr(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  AppStrings.homeTagline.tr(),
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          // Offers
          _HeaderIconButton(
            icon: AppImages.offers,
            fallbackIcon: Icons.local_offer_outlined,
            onTap: () => AppNavigator.push(const OffersListScreen()),
          ),
          const SizedBox(width: 10),
          // Notification
          _HeaderIconButton(
            icon: AppImages.notification,
            fallbackIcon: Icons.notifications_outlined,
            onTap: () => AppNavigator.push(const NotificationsScreen()),
          ),
        ],
      ),
    );
  }

  // ── Featured Banner(s) — real `ad_banner` section items ─────────
  Widget _buildFeaturedBanner() {
    final section = _homeState.bannerSection;
    final banners = section?.banners ?? const <HomeBannerItem>[];

    if (banners.isEmpty) {
      if (_homeState.status == HomeStatus.loading) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: PromoBanner.height,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: PromoBanner.height,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: banners.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: i == banners.length - 1 ? 16 : 8,
            ),
            child: PromoBanner(
              imageUrl: banners[i].image,
              onTap: () => openHomeBannerItem(banners[i]),
            ),
          );
        },
      ),
    );
  }

  // ── Category Chips (real `corners` section items) ───────────────
  Widget _buildCategoryChips() {
    final corners =
        _homeState.cornersSection?.corners ?? const <HomeCornerItem>[];
    if (corners.isEmpty) return const SizedBox.shrink();

    const tileSize = 68.0;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: tileSize,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          // +1 for the leading "All" tile.
          itemCount: corners.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return GestureDetector(
                onTap: () => AppNavigator.push(const CornersListScreen()),
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Text(
                    AppStrings.tabAll.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }

            final corner = corners[i - 1];
            return GestureDetector(
              onTap: () =>
                  AppNavigator.push(CornerScreen(cornerId: corner.id)),
              child: Container(
                width: tileSize,
                height: tileSize,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _homeImage(
                  corner.image,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.auto_stories_outlined,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    VoidCallback? onTap, {
    bool showSeeAll = true,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: onTap,
              child: Text(
                AppStrings.seeAll.tr(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Latest Issues ─────────────────────────────────────────────
  Widget _buildLatestIssues() {
    final issues = _issueModels;
    return SizedBox(
      height: 262,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: issues.length,
        itemBuilder: (context, i) {
          final item = issues[i];
          return _IssueCard(item: item);
        },
      ),
    );
  }

  // ── Articles ──────────────────────────────────────────────────
  Widget _buildArticlesList() {
    return Column(
      children: _articleModels.map((a) => _ArticleRow(article: a)).toList(),
    );
  }

  // ── Writers & Authors (real `writers_authors` section items) ─────
  Widget _buildAuthors() {
    final authors = _authorModels;
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: authors.length,
        itemBuilder: (context, i) {
          return _AuthorChip(author: authors[i]);
        },
      ),
    );
  }

  // ── Best Books ────────────────────────────────────────────────
  Widget _buildBestBooks() {
    final books = _bookModels;
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: books.length,
        itemBuilder: (context, i) {
          final book = books[i];
          return _BookCard(book: book);
        },
      ),
    );
  }

  // ── Fresh News ────────────────────────────────────────────────
  Widget _buildFreshNews() {
    return Column(
      children: _newsModels.map((n) => _NewsCard(news: n)).toList(),
    );
  }

  // ── Recommendations (reuses the Best Books data — no separate API) ─
  Widget _buildRecommendations() {
    final books = _bookModels;
    return SizedBox(
      height: 252,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: books.length,
        itemBuilder: (context, i) {
          final book = books[i];
          return _RecommendationCard(book: book);
        },
      ),
    );
  }
}

// ============================================
// ISSUE CARD WIDGET
// ============================================

class _IssueCard extends StatelessWidget {
  final IssueModel item;
  const _IssueCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.push(IssueDetailsScreen(issueId: item.id)),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _homeImage(
                item.image,
                width: 130,
                height: 200,
                fit: BoxFit.cover,
                fallbackIcon: Icons.book_outlined,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item.date,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            _PriceLabel(price: item.price),
          ],
        ),
      ),
    );
  }
}

// ============================================
// ARTICLE ROW WIDGET
// ============================================

class _ArticleRow extends StatelessWidget {
  final ArticleModel article;
  const _ArticleRow({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.push(ArticleScreen(articleId: article.id)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: _cardDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _homeImage(
                article.image,
                width: 96,
                height: 110,
                fit: BoxFit.cover,
                fallbackIcon: Icons.image_outlined,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    article.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _PriceLabel(price: article.price),
                  const SizedBox(height: 2),
                  _StarRating(rating: article.rating),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      article.date,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// AUTHOR CHIP
// ============================================

class _AuthorChip extends StatelessWidget {
  final AuthorModel author;
  const _AuthorChip({required this.author});

  static const double _size = 92;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
      color: AppColors.accentPale,
      alignment: Alignment.bottomCenter,
      child: const Icon(Icons.person, size: 84, color: AppColors.primary),
    );

    final image = author.image;
    return GestureDetector(
      onTap: () => AppNavigator.push(AuthorScreen(authorId: author.id)),
      child: SizedBox(
      width: _size,
      child: Column(
        children: [
          Container(
            width: _size,
            height: _size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: (image != null && image.isNotEmpty)
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    // Placeholder while loading, not a blank box.
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : placeholder(),
                    errorBuilder: (_, __, ___) => placeholder(),
                  )
                : placeholder(),
          ),
          const SizedBox(height: 6),
          Text(
            author.name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      ),
    );
  }
}

// ============================================
// BOOK CARD
// ============================================

class _BookCard extends StatelessWidget {
  final BookModel book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.push(BookScreen(bookId: book.id)),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _homeImage(
                book.image,
                width: 130,
                height: 200,
                fit: BoxFit.cover,
                fallbackIcon: Icons.book_outlined,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.author,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            _PriceLabel(price: book.price),
            const SizedBox(height: 2),
            _StarRating(rating: book.rating),
          ],
        ),
      ),
    );
  }
}

// ============================================
// NEWS CARD
// ============================================

class _NewsCard extends StatelessWidget {
  final NewsModel news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.push(ArticleScreen(articleId: news.id)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inset image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _homeImage(
                news.image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                fallbackIcon: Icons.newspaper_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                  ),
                  if (news.description != null &&
                      news.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      news.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      news.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// RECOMMENDATION CARD
// ============================================

class _RecommendationCard extends StatelessWidget {
  final BookModel book;
  const _RecommendationCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.push(BookScreen(bookId: book.id)),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _homeImage(
                book.image,
                width: 130,
                height: 200,
                fit: BoxFit.cover,
                fallbackIcon: Icons.book_outlined,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.author,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// HEADER ICON BUTTON (Offers / Notification)
// ============================================

class _HeaderIconButton extends StatelessWidget {
  final String icon;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentPale,
        ),
        alignment: Alignment.center,
        child: Image.asset(
          icon,
          width: 20,
          height: 20,
          color: AppColors.primary,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (_, __, ___) =>
              Icon(fallbackIcon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }
}

// ============================================
// STAR RATING
// ============================================

class _StarRating extends StatelessWidget {
  final double rating;
  final int total;
  const _StarRating({required this.rating, this.total = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        return Icon(
          i < rating.floor()
              ? Icons.star
              : (i < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 13,
        );
      }),
    );
  }
}

// ============================================
// PRICE LABEL — "35.09 SAR" with the amount grey and currency maroon
// ============================================

class _PriceLabel extends StatelessWidget {
  final String price;
  const _PriceLabel({required this.price});

  @override
  Widget build(BuildContext context) {
    final currency = AppStrings.currencySar.tr();
    final hasCurrency = price.endsWith(' $currency');
    final amount = hasCurrency
        ? price.substring(0, price.length - currency.length)
        : '';

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        children: [
          if (hasCurrency)
            TextSpan(
              text: amount,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          TextSpan(text: hasCurrency ? currency : price),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
