
import 'dart:async';
import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/data/models/user_model.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:albayan/fatures/corners/screens/corners_list_screen.dart';
import 'package:albayan/fatures/issues/screens/issues_screen.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/utils/shared_pref_helper.dart';
import 'package:flutter/material.dart';

// ============================================
// DATA MODELS (lightweight, inline)
// ============================================

class IssueModel {
  final String image;
  final String title;
  final String date;
  final String price;
  IssueModel({required this.image, required this.title, required this.date, required this.price});
}

class ArticleModel {
  final String image;
  final String category;
  final String title;
  final String author;
  final String price;
  final String date;
  final double rating;
  ArticleModel({
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
  final String? image;
  final String name;
  AuthorModel({this.image, required this.name});
}

class BookModel {
  final String image;
  final String title;
  final String author;
  final String price;
  final double rating;
  BookModel({required this.image, required this.title, required this.author, required this.price, required this.rating});
}

class NewsModel {
  final String image;
  final String title;
  final String description;
  final String timeAgo;
  NewsModel({required this.image, required this.title, required this.description, required this.timeAgo});
}

// ============================================
// HOME SCREEN
// ============================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  // ── Profile ────────────────────────────────────────────────────
  UserModel? _user;
  late final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(AuthRemoteDataSource(ApiService()));

    // Show cached profile data instantly, then refresh from the API.
    _user = SharedPrefHelper.getUser();
    _loadProfile();
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

  @override
  void dispose() {
    _authSub?.cancel();
    _authCubit.close();
    super.dispose();
  }

  final List<String> _categories = [
    'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=300', // Poetry/Modern Book
    'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=300', // Classic Fiction
    'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&q=80&w=300', // Open Educational Book
    'https://images.unsplash.com/photo-1614849963640-9cc74b2a826f?auto=format&fit=crop&q=80&w=300', // Minimalist Book Cover
    'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=300', // Vintage/Hardcover Book
    'https://images.unsplash.com/photo-1495640388908-05fa85288e61?auto=format&fit=crop&q=80&w=300', // Novel/Paperback Stack
  ];

  final List<IssueModel> _issues = [
    IssueModel(image: 'assets/images/issue1.jpg', title: 'Dark woods, 0904', date: 'May 3, 2025', price: '35.09 SAR'),
    IssueModel(image: 'assets/images/issue2.jpg', title: 'Dark woods, 0904', date: 'May 3, 2025', price: '35.09 SAR'),
    IssueModel(image: 'assets/images/issue3.jpg', title: 'Dark woods, 0904', date: 'May 3, 2025', price: '35.09 SAR'),
  ];

  final List<ArticleModel> _articles = [
    ArticleModel(image: 'assets/images/art1.jpg', category: 'Lorem lorem . 0908', title: 'Adobe abandons \$20 billion acquisition of Figma', author: 'Dr. Ahmad Hassan', price: '35.09 SAR', date: 'May 6,2026', rating: 4),
    ArticleModel(image: 'assets/images/art2.jpg', category: 'Lorem lorem . 0908', title: 'Adobe abandons \$20 billion acquisition of Figma', author: 'Dr. Ahmad Hassan', price: '38.19 SAR', date: 'May 6,2026', rating: 4),
    ArticleModel(image: 'assets/images/art3.jpg', category: 'Lorem lorem . 0908', title: 'Adobe abandons \$20 billion acquisition of Figma', author: 'Dr. Ahmad Hassan', price: '26.09 SAR', date: 'May 6,2026', rating: 4),
    ArticleModel(image: 'assets/images/art4.jpg', category: 'Lorem lorem . 0908', title: 'Adobe abandons \$20 billion acquisition of Figma', author: 'Dr. Ahmad Hassan', price: '38.18 SAR', date: 'May 6,2026', rating: 4),
  ];

  final List<AuthorModel> _authors = [
    AuthorModel(name: 'Sarah Ahmad'),
    AuthorModel(name: 'Ahmad Ali'),
    AuthorModel(name: 'Sarah Ahmad'),
    AuthorModel(name: 'Ahmad Ali'),
  ];

  final List<BookModel> _books = [
    BookModel(image: 'assets/images/book1.jpg', title: 'Dark woods, 0904', author: 'Dr. Ahmad Hassan', price: '35.09 SAR', rating: 4),
    BookModel(image: 'assets/images/book2.jpg', title: 'Dark woods, 0904', author: 'Dr. Ahmad Hassan', price: '38.19 SAR', rating: 4),
    BookModel(image: 'assets/images/book3.jpg', title: 'Dark woods, 0904', author: 'Dr. Ahmad Hassan', price: '26.09 SAR', rating: 4),
  ];

  final List<NewsModel> _news = [
    NewsModel(image: 'assets/images/news1.jpg', title: 'Adobe abandons \$20 billion acquisition of Figma', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad', timeAgo: '23 min ago'),
    NewsModel(image: 'assets/images/news2.jpg', title: 'Adobe abandons \$20 billion acquisition of Figma', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad', timeAgo: '23 min ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Featured Banner ──────────────────────────────────
            SliverToBoxAdapter(child: _buildFeaturedBanner()),

            // ── Category Chips ───────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader('Corners', () {
              AppNavigator.push(const CornersListScreen());
            },),),
            SliverToBoxAdapter(child: _buildCategoryChips()),

            // ── Latest Issues ────────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader('Latest Issues',() {
              AppNavigator.push(const IssuesScreen());
            },),),
            SliverToBoxAdapter(child: _buildLatestIssues()),

            // ── Articles ─────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader('Articles',null)),
            SliverToBoxAdapter(child: _buildArticlesList()),

            // ── Writers & Authors ─────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader('Writers & Authors',null)),
            SliverToBoxAdapter(child: _buildAuthors()),

            // ── Best Books ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader('Best Books in 2026',null)),
            SliverToBoxAdapter(child: _buildBestBooks()),

            // ── Fresh News ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader('Fresh News',null)),
            SliverToBoxAdapter(child: _buildFreshNews()),

            // ── Recommendations ──────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader('Recommendation',null)),
            SliverToBoxAdapter(child: _buildRecommendations()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    final isLoggedIn   = SharedPrefHelper.isLoggedIn();
    final displayName  = _user?.displayName ?? (isLoggedIn ? 'Reader' : 'Guest');
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
                    Icons.person, color: AppColors.textSecondary, size: 26),
              )
                  : Icon(Icons.person, color: AppColors.textSecondary, size: 26),
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
                        'Hello, $displayName',
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentPale,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _user?.subscriptionStatus ?? 'Active',
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
                  'Discover stories, knowledge and inspiration',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          // Offers
          _HeaderIconButton(
            icon: AppImages.offers,
            fallbackIcon: Icons.local_offer_outlined,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          // Notification
          _HeaderIconButton(
            icon: AppImages.notification,
            fallbackIcon: Icons.notifications_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Featured Banner ───────────────────────────────────────────
  Widget _buildFeaturedBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Left text content
          Positioned(
            left: 16,
            top: 20,
            bottom: 20,
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Future of\nDigital Reading',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover how technology is shaping\nreaders reading experiences.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Read Now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right stacked book images
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _bannerBookCard('assets/images/book1.jpg', rotate: -0.1),
                const SizedBox(width: 4),
                _bannerBookCard('assets/images/issue1.jpg', rotate: 0.05),
                const SizedBox(width: 4),
                _bannerBookCard('assets/images/issue2.jpg', rotate: 0.12),
              ],
            ),
          ),
          // Empty Boat label
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text('EMPTY', style: TextStyle(color: Colors.white, fontSize: 8, letterSpacing: 1)),
                  Text('BOAT', style: TextStyle(color: Colors.white, fontSize: 8, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerBookCard(String imagePath, {double rotate = 0}) {
    return Transform.rotate(
      angle: rotate,
      child: Container(
        width: 44,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColors.surfaceVariant,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(2, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: _networkOrPlaceholder(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // ── Category Chips ────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 75,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = i),
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  // Dynamically load the image from the URL list based on index
                  image: NetworkImage(_categories[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────
  Widget _buildSectionHeader(String title, onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'See All',
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
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _issues.length,
        itemBuilder: (context, i) {
          final item = _issues[i];
          return _IssueCard(item: item);
        },
      ),
    );
  }

  // ── Articles ──────────────────────────────────────────────────
  Widget _buildArticlesList() {
    return Column(
      children: _articles.map((a) => _ArticleRow(article: a)).toList(),
    );
  }

  // ── Authors ───────────────────────────────────────────────────
  Widget _buildAuthors() {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: _authors.length,
        itemBuilder: (context, i) {
          return _AuthorChip(author: _authors[i]);
        },
      ),
    );
  }

  // ── Best Books ────────────────────────────────────────────────
  Widget _buildBestBooks() {
    return SizedBox(
      height: 228,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _books.length,
        itemBuilder: (context, i) {
          final book = _books[i];
          return _BookCard(book: book);
        },
      ),
    );
  }

  // ── Fresh News ────────────────────────────────────────────────
  Widget _buildFreshNews() {
    return Column(
      children: _news.map((n) => _NewsCard(news: n)).toList(),
    );
  }

  // ── Recommendations ───────────────────────────────────────────
  Widget _buildRecommendations() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _books.length,
        itemBuilder: (context, i) {
          final book = _books[i];
          return _RecommendationCard(book: book);
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _networkOrPlaceholder(String path, {BoxFit fit = BoxFit.cover}) {
    // Try asset, fallback to colored placeholder
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceVariant,
        child: Center(
          child: Icon(Icons.image_outlined, color: AppColors.textLight, size: 28),
        ),
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
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: Center(child: Icon(Icons.book_outlined, color: AppColors.textLight, size: 32)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.date,
            style: TextStyle(fontSize: 10, color: AppColors.textLight),
          ),
          Row(
            children: [
              Text(
                item.price,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  // decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
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
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              article.image,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_outlined, color: AppColors.textLight, size: 28),
              ),
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
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                const SizedBox(height: 2),
                Text(
                  article.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                  maxLines: 2,
                ),
                const SizedBox(height: 3),
                Text(
                  article.author,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      article.price,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        // decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article.date,
                      style: TextStyle(fontSize: 10, color: AppColors.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _StarRating(rating: article.rating),
              ],
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.surfaceVariant,
          child: author.image != null
              ? ClipOval(child: Image.asset(author.image!, fit: BoxFit.cover, width: 64, height: 64, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30, color: AppColors.textLight)))
              : const Icon(Icons.person, size: 30, color: AppColors.textLight),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            author.name,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              book.image,
              width: 130,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 130,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.book_outlined, color: AppColors.textLight, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(book.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(book.author, style: TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(book.price, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 2),
          _StarRating(rating: book.rating),
        ],
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              news.image,
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 170,
                color: AppColors.surfaceVariant,
                child: const Center(child: Icon(Icons.newspaper_outlined, color: AppColors.textLight, size: 48)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Text(
                  news.description,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    news.timeAgo,
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              book.image,
              width: 130,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 130,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.book_outlined, color: AppColors.textLight, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(book.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(book.author, style: TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('May 3, 2026', style: TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
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
          i < rating.floor() ? Icons.star : (i < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 13,
        );
      }),
    );
  }
}