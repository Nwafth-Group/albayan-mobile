// ============================================
// FILE: lib/fatures/issues/screens/issue_details_screen.dart
// ============================================

import 'package:albayan/fatures/corners/screens/corner_screen.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:albayan/widgets/index_article_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/detail_hero.dart';
import '../../../widgets/detail_tabs.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/promo_banner.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../cart/utils/add_to_cart_mixin.dart';
import '../../library/utils/add_to_library_mixin.dart';
import '../../library/screens/library_screen.dart';
import '../../settings/screens/subscriptions_screen.dart';
import '../data/datasource/issues_remote_data_source.dart';
import '../data/models/issue_detail_model.dart';
import 'cubit/issue_details_cubit.dart';

class IssueDetailsScreen extends StatelessWidget {
  final String issueId;

  const IssueDetailsScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = IssuesRemoteDataSourceImpl(ApiService());
        return IssueDetailsCubit(dataSource, issueId: issueId)..load();
      },
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatefulWidget {
  const _DetailsView();

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView>
    with AddToCartStateMixin, AddToLibraryStateMixin {
  int _tab = 0; // 0 = Short Word, 1 = Issue Index

  /// Free issue → "Read Now": add it to My Library (no checkout), then show
  /// its articles (the Issue Index tab).
  Future<void> _readFree(IssueDetailModel detail) async {
    await addFreeToLibrary(
      type: LibraryItemType.issue,
      id: detail.id,
      alreadyInLibrary: detail.isBought,
    );
    if (mounted) setState(() => _tab = 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueDetailsCubit, IssueDetailsState>(
      builder: (context, state) {
        switch (state.status) {
          case DetailsStatus.initial:
          case DetailsStatus.loading:
            return const LoadingWidget();

          case DetailsStatus.failure:
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: CustomAppBar(title: AppStrings.detailsPage.tr()),
              body: EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.somethingWentWrong.tr(),
                message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
                actionText: AppStrings.retry.tr(),
                onAction: () => context.read<IssueDetailsCubit>().load(),
              ),
            );

          case DetailsStatus.success:
            return Scaffold(
              backgroundColor: AppColors.background,
              body: _buildContent(context, state.detail!),
            );
        }
      },
    );
  }

  Widget _buildContent(BuildContext context, IssueDetailModel detail) {
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * 0.5;
    const overlap = 30.0;

    // SizedBox.expand forces the Stack to fill the body; otherwise the Stack
    // would collapse to the hero's height and the card would be ~30px tall.
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: DetailHero(
              coverUrl: detail.coverImage,
              title: detail.title,
              subtitle: _headerDate(context, detail),
              topBar: DetailTopBar(
                title: AppStrings.detailsPage.tr(),
                actions: [
                  DetailCircleAction(
                    asset: AppImages.taj, // crown / subscription
                    onTap: () => AppNavigator.push(const SubscriptionsScreen()),
                  ),
                  DetailCircleAction(
                    asset: AppImages.openBook, // read
                    onTap: () => detail.isFree
                        ? _readFree(detail)
                        : detail.isBought
                        ? AppNavigator.push(const LibraryScreen())
                        : addToCart(type: CartItemType.issue, id: detail.id),
                  ),
                  DetailFavoriteAction(
                    isFavorite: detail.isFavorite,
                    onTap: () =>
                        context.read<IssueDetailsCubit>().toggleFavorite(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: heroHeight - overlap,
            left: 0,
            right: 0,
            bottom: 0,
            child: _card(context, detail),
          ),
        ],
      ),
    );
  }

  // ── Card ────────────────────────────────────────────────
  Widget _card(BuildContext context, IssueDetailModel detail) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
        AppDimensions.paddingMedium + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailTabs(
            labels: [AppStrings.shortWord.tr(), AppStrings.issueIndex.tr()],
            selectedIndex: _tab,
            spacing: 36,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Expanded(
            child: _tab == 0
                ? _shortWord(context, detail)
                : _issueIndex(context, detail),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buttons(context, detail),
        ],
      ),
    );
  }

  // ── Short Word tab ──────────────────────────────────────
  Widget _shortWord(BuildContext context, IssueDetailModel detail) {
    final intro = detail.shortIntroduction;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdPromoBanner(
            padding: EdgeInsets.only(bottom: AppDimensions.paddingLarge),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  intro?.title ?? detail.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(
                AppStrings.editorialStaff.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeSmall,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            intro?.summary ?? '',
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.75,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Issue Index tab ─────────────────────────────────────
  Widget _issueIndex(BuildContext context, IssueDetailModel detail) {
    if (detail.indexPreview.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noResults.tr(),
          style: const TextStyle(color: AppColors.textLight),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: detail.indexPreview.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.paddingMedium),
      itemBuilder: (_, i) => IndexArticleTile(
        item: detail.indexPreview[i],
        onTap: () {
          AppNavigator.push(
            CornerScreen(cornerId: detail.indexPreview[i].corner!.id),
          );
        },
      ),
    );
  }

  // ── Buttons (shared) ────────────────────────────────────
  Widget _buttons(BuildContext context, IssueDetailModel detail) {
    final cartText = '${AppStrings.addToCart.tr()} '
        '${detail.price.toStringAsFixed(2)}${AppStrings.currencySar.tr()}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: CustomButton(
                text: detail.isFree
                    ? AppStrings.readNow.tr()
                    : AppStrings.read.tr(),
                isOutlined: !detail.isFree,
                textColor: detail.isFree ? null : AppColors.primary,
                isLoading: detail.isFree && isAddingToLibrary,
                onPressed: detail.isFree
                    ? () => _readFree(detail)
                    : () {
                        // TODO: open reader
                      },
              ),
            ),
            if (!detail.isFree) ...[
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: cartText,
                  fontSize: AppDimensions.fontSizeMedium,
                  isLoading: isAddingToCart,
                  onPressed: () =>
                      addToCart(type: CartItemType.issue, id: detail.id),
                ),
              ),
            ],
          ],
        ),
        // Nothing to gift on free content.
        if (!detail.isFree) ...[
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: AppStrings.gift.tr(),
                backgroundColor: AppColors.surfaceVariant,
                textColor: AppColors.primary,
                isLoading: isAddingGift,
                onPressed: () =>
                    addGiftToCart(type: CartItemType.issue, id: detail.id),
              ),
            ),
          ],
        ),
        ],
      ],
    );
  }

  // ── Date line: "May 7, 2026 | Dhu al-Hijjah 1447 AH" ────
  String _headerDate(BuildContext context, IssueDetailModel d) {
    final greg = d.publishedAt != null
        ? DateFormat('MMM d, yyyy', 'en').format(d.publishedAt!)
        : '';
    final isAr = context.locale.languageCode == 'ar';
    final hMonth = isAr ? d.hMonthNameAr : d.hMonthNameEn;
    final hijri = '$hMonth ${d.hYear} ${AppStrings.hijriSuffix.tr()}';
    return greg.isEmpty ? hijri : '$greg | $hijri';
  }
}
