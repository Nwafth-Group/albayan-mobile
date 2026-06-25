// ============================================
// FILE: lib/fatures/issues/screens/issue_details_screen.dart
// ============================================

import 'dart:ui';

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
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
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

class _DetailsViewState extends State<_DetailsView> {
  int _tab = 0; // 0 = Short Word, 1 = Issue Index

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
            child:
            _Hero(detail: detail, dateText: _headerDate(context, detail)),
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
          _tabs(context),
          const SizedBox(height: AppDimensions.paddingLarge),
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

  Widget _tabs(BuildContext context) {
    return Row(
      children: [
        _TabItem(
          label: AppStrings.shortWord.tr(),
          selected: _tab == 0,
          onTap: () => setState(() => _tab = 0),
        ),
        const SizedBox(width: AppDimensions.paddingLarge),
        _TabItem(
          label: AppStrings.issueIndex.tr(),
          selected: _tab == 1,
          onTap: () => setState(() => _tab = 1),
        ),
      ],
    );
  }

  // ── Short Word tab ──────────────────────────────────────
  Widget _shortWord(BuildContext context, IssueDetailModel detail) {
    final intro = detail.shortIntroduction;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  intro?.title ?? detail.title,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(
                AppStrings.editorialStaff.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeSmall,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            intro?.summary ?? '',
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              height: 1.7,
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
    final cartText = detail.isFree
        ? AppStrings.addToCart.tr()
        : '${AppStrings.addToCart.tr()} '
        '${detail.price.toStringAsFixed(2)}${AppStrings.currencySar.tr()}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: CustomButton(
                text: AppStrings.read.tr(),
                isOutlined: true,
                textColor: AppColors.primary,
                onPressed: () {
                  // TODO: open reader
                },
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: cartText,
                fontSize: AppDimensions.fontSizeMedium,
                onPressed: () {
                  // TODO: add to cart
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingxSmall),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: AppStrings.gift.tr(),
                backgroundColor: AppColors.surfaceVariant,
                textColor: AppColors.primary,
                onPressed: () {
                  // TODO: gift flow
                },
              ),
            ),
          ],
        ),
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

// ── Hero header ───────────────────────────────────────────
class _Hero extends StatelessWidget {
  final IssueDetailModel detail;
  final String dateText;

  const _Hero({required this.detail, required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background of the same cover
        _BlurredCover(url: detail.coverImage),
        // Scrim for text legibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.transparent,
                Colors.black.withOpacity(0.45),
              ],
              stops: const [0, 0.4, 1],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _topBar(context),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: AspectRatio(
                        aspectRatio: 0.82,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _SharpCover(url: detail.coverImage),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    detail.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    dateText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => AppNavigator.pop(),
        ),
        Text(
          AppStrings.detailsPage.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        _CircleAction(
          asset: AppImages.taj,        // crown / subscription
          onTap: () {
            // TODO: subscription
          },
        ),
        const SizedBox(width: 4,),
        _CircleAction(
          asset: AppImages.openBook,   // read
          onTap: () {
            // TODO: read
          },
        ),
        const SizedBox(width: 4,),
        _CircleAction(
          asset: AppImages.favorate,   // favorite
          onTap: () => context.read<IssueDetailsCubit>().toggleFavorite(),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final double size;

  const _CircleAction({
    required this.asset,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _BlurredCover extends StatelessWidget {
  final String? url;
  const _BlurredCover({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(color: AppColors.surfaceVariant);
    }
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.surfaceVariant),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withOpacity(0.15)),
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
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 40),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 40),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: selected ? AppColors.textPrimary : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: 36,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}