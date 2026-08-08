
// ============================================
// FILE: lib/fatures/books/screens/book_screen.dart
// ============================================

import 'package:albayan/fatures/articles/screens/widgets/rate_experience_sheet.dart';
import 'package:albayan/widgets/custom_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/datasource/books_remote_data_source.dart';
import 'cubit/book_cubit.dart';
import 'widgets/about_book_tab.dart';
import 'widgets/book_info_bar.dart';
import 'widgets/related_tab.dart';
import 'widgets/reviews_tab.dart';

class BookScreen extends StatelessWidget {
  final String bookId;
  const BookScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookCubit(
        BooksRemoteDataSourceImpl(ApiService()),
        bookId: bookId,
      )..load(),
      child: const _BookView(),
    );
  }
}

class _BookView extends StatefulWidget {
  const _BookView();

  @override
  State<_BookView> createState() => _BookViewState();
}

class _BookViewState extends State<_BookView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openRating() async {
    final cubit = context.read<BookCubit>();
    final result = await showRateExperienceSheet(context);
    if (result == null) return;
    final ok = await cubit.submitRating(
      rating: result.rating,
      comment: result.comment,
    );
    if (!mounted) return;
    if (ok) {
      Helpers.showSuccess(context, AppStrings.feedbackSent.tr());
    } else {
      Helpers.showError(AppStrings.somethingWentWrong.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      body: BlocBuilder<BookCubit, BookState>(
        builder: (context, state) {
          if (state.status == BookStatus.loading && state.book == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.status == BookStatus.failure && state.book == null) {
            return SafeArea(
              child: EmptyStateWidget(
                icon: Icons.wifi_off_rounded,
                message: AppStrings.somethingWentWrong.tr(),
                message2: state.error,
                actionText: AppStrings.retry.tr(),
                onAction: () => context.read<BookCubit>().load(),
              ),
            );
          }

          final book = state.book!;
          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              _buildHeader(context, state),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.paddingMedium,
                    bottom: AppDimensions.paddingSmall,
                  ),
                  child: BookInfoBar(book: book),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    dividerColor: AppColors.cardColor,
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textLight,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(text: AppStrings.aboutBook.tr()),
                      Tab(text: AppStrings.reviews.tr()),
                      Tab(text: AppStrings.relatedBooks.tr()),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                AboutBookTab(book: book),
                ReviewsTab(
                  book: book,
                  comments: state.comments,
                  loadingMore: state.commentsStatus == ListStatus.loadingMore,
                  onLoadMore: () =>
                      context.read<BookCubit>().loadMoreComments(),
                ),
                RelatedTab(
                  items: state.related,
                  loadingMore: state.relatedStatus == ListStatus.loadingMore,
                  onLoadMore: () =>
                      context.read<BookCubit>().loadMoreRelated(),
                  onItemTap: (b) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookScreen(bookId: b.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ---- Header (image + title) ----
  Widget _buildHeader(BuildContext context, BookState state) {
    final book = state.book!;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 320,
      backgroundColor: const Color(0xFF2A2A2A),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        AppStrings.bookDetails.tr(),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: false,
      actions: [
        _circleAction(
          child: ImageAsset(AppImages.openBook, width: 20, height: 20),
          onTap: () {/* TODO: open reader */},
        ),
        _circleAction(
          child: ImageAsset(AppImages.favorate, width: 20, height: 20),
          onTap: () => context.read<BookCubit>().toggleFavorite(),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (book.image != null)
              Image.network(
                book.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF2A2A2A)),
              )
            else
              Container(color: const Color(0xFF2A2A2A)),
            // Darken for legibility
            Container(color: Colors.black.withOpacity(0.45)),
            // Centered cover + title
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: (book.image != null)
                            ? Image.network(
                                book.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                    color: AppColors.surfaceVariant),
                              )
                            : const ColoredBox(color: AppColors.surfaceVariant),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppDimensions.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleAction({required Widget child, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: child,
        ),
      ),
    );
  }

  // ---- Bottom bar (switches by tab) ----
  Widget? _buildBottomBar(BuildContext context) {
    final state = context.watch<BookCubit>().state;
    final book = state.book;
    if (book == null) return null;

    final isReviews = _tabController.index == 1;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: isReviews
            ? (book.allowedRating
                ? CustomButton(
                    text: AppStrings.addRating.tr(),
                    isLoading: state.submittingRating,
                    onPressed: _openRating,
                  )
                : const SizedBox.shrink())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.read.tr(),
                          isOutlined: true,
                          textColor: AppColors.primary,
                          onPressed: () {/* TODO: open reader */},
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: book.isFree
                              ? AppStrings.addToCart.tr()
                              : '${AppStrings.addToCart.tr()} ${book.effectivePrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
                          onPressed: () {/* TODO: add to cart */},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: AppStrings.gift.tr(),
                      isOutlined: true,
                      textColor: AppColors.primary,
                      onPressed: () {/* TODO: gift */},
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Pinned TabBar header for the NestedScrollView.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: AppColors.cardColor,
      alignment: Alignment.centerLeft,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}
