
// ============================================
// FILE: lib/fatures/publishers/screens/publisher_screen.dart
// ============================================

import 'package:albayan/fatures/books/screens/book_screen.dart';
import 'package:albayan/fatures/books/screens/widgets/book_grid_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/datasource/publishers_remote_data_source.dart';
import '../data/models/publisher_detail_model.dart';
import 'cubit/publisher_cubit.dart';
import 'widgets/publisher_promo_card.dart';
import 'widgets/publisher_social_footer.dart';

class PublisherScreen extends StatelessWidget {
  final String publisherId;
  const PublisherScreen({super.key, required this.publisherId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublisherCubit(
        PublishersRemoteDataSourceImpl(ApiService()),
        publisherId: publisherId,
      )..load(),
      child: const _PublisherView(),
    );
  }
}

class _PublisherView extends StatefulWidget {
  const _PublisherView();

  @override
  State<_PublisherView> createState() => _PublisherViewState();
}

class _PublisherViewState extends State<_PublisherView> {
  final _scrollController = ScrollController();
  final _relatedBooksKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<PublisherCubit>().loadMoreBooks();
    }
  }

  void _scrollToBooks() {
    final ctx = _relatedBooksKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      body: BlocBuilder<PublisherCubit, PublisherState>(
        builder: (context, state) {
          if (state.status == PublisherStatus.loading &&
              state.publisher == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.status == PublisherStatus.failure &&
              state.publisher == null) {
            return SafeArea(
              child: EmptyStateWidget(
                icon: Icons.wifi_off_rounded,
                message: AppStrings.somethingWentWrong.tr(),
                message2: state.error,
                actionText: AppStrings.retry.tr(),
                onAction: () => context.read<PublisherCubit>().load(),
              ),
            );
          }

          final publisher = state.publisher!;
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildHeader(context, publisher),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingMedium,
                    AppDimensions.paddingLarge,
                    AppDimensions.paddingMedium,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About
                      Text(
                        AppStrings.aboutPublisherHouse.tr(),
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (publisher.description != null &&
                          publisher.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Text(
                          publisher.description!,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeMedium,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Discover promo
                      PublisherPromoCard(
                        logo: publisher.logo,
                        bookCovers: state.books
                            .map((b) => b.image)
                            .whereType<String>()
                            .toList(),
                        onDiscover: _scrollToBooks,
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Related books header
                      Text(
                        AppStrings.relatedBooks.tr(),
                        key: _relatedBooksKey,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                    ],
                  ),
                ),
              ),
              _buildBooksGrid(context, state),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingMedium,
                    AppDimensions.paddingLarge,
                    AppDimensions.paddingMedium,
                    AppDimensions.paddingLarge,
                  ),
                  child: PublisherSocialFooter(
                    socialLinks: publisher.socialLinks,
                    email: publisher.email,
                    onTapLink: (url) {
                      // TODO: open external link (needs a url launcher dep).
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBooksGrid(BuildContext context, PublisherState state) {
    if (state.booksStatus == ListStatus.loading && state.books.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }
    if (state.books.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStateWidget(
          image: AppImages.noData,
          message: AppStrings.noPublisherBooks.tr(),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.paddingMedium,
          crossAxisSpacing: AppDimensions.paddingMedium,
          childAspectRatio: 0.52,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = state.books[index];
            return BookGridCard(
              book: book,
              onTap: () => AppNavigator.push(BookScreen(bookId: book.id)),
              onCartTap: () {
                // TODO: add to cart.
              },
            );
          },
          childCount: state.books.length,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PublisherDetailModel publisher) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 340,
      backgroundColor: const Color(0xFF2A2A2A),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        AppStrings.publisherHouse.tr(),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: false,
      actions: [
        _circleAction(
          icon: Icons.ios_share,
          onTap: () {
            // TODO: share publisher (needs a share/url-launcher dep).
          },
        ),
        _circleAction(
          icon: Icons.favorite_border,
          onTap: () {
            // TODO: favorite endpoint not exposed for publishers yet.
          },
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (publisher.logo != null && publisher.logo!.isNotEmpty)
              Image.network(
                publisher.logo!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.surfaceDark),
              )
            else
              Container(color: AppColors.surfaceDark),
            // Warm tint for legibility.
            Container(color: AppColors.textPrimary.withOpacity(0.35)),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: _buildHeaderContent(publisher),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent(PublisherDetailModel publisher) {
    final country = publisher.country;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 170,
          height: 170,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Text(
            publisher.name,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppDimensions.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
        ),
        if (country != null) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                country.nameEn,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppDimensions.fontSizeMedium,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _circleAction({required IconData icon, VoidCallback? onTap}) {
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
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
