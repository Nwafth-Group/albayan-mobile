
// ============================================
// FILE: lib/fatures/offers/screens/offers_list_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/offers_remote_data_source.dart';
import '../data/models/offer_model.dart';
import 'content_offer_screen.dart';
import 'cubit/offers_list_cubit.dart';
import 'issue_offer_screen.dart';
import 'package_offer_screen.dart';
import 'widgets/offer_card.dart';
import 'widgets/offer_countdown_banner.dart';
import 'widgets/offer_type_tabs.dart';

class OffersListScreen extends StatelessWidget {
  const OffersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OffersListCubit(OffersRemoteDataSourceImpl(ApiService()))..load(),
      child: const _OffersListView(),
    );
  }
}

/// Opens the right offer page for [offer]. [content] is passed when it's
/// already loaded (a campaign from `/public/offers/{id}`).
void openOfferScreen(OfferModel offer, {OfferContent? content}) {
  switch (offer.type) {
    case OfferType.package:
      AppNavigator.push(
        PackageOfferScreen(offer: offer, initialContent: content),
      );
      break;
    case OfferType.issue:
      AppNavigator.push(IssueOfferScreen(offer: offer, initialContent: content));
      break;
    case OfferType.book:
    case OfferType.article:
      AppNavigator.push(
        ContentOfferScreen(offer: offer, initialContent: content),
      );
      break;
  }
}

class _OffersListView extends StatefulWidget {
  const _OffersListView();

  @override
  State<_OffersListView> createState() => _OffersListViewState();
}

class _OffersListViewState extends State<_OffersListView> {
  final _scrollController = ScrollController();

  // Tab order matches the labels below; `null` is "all".
  static const _types = [
    null,
    OfferType.package,
    OfferType.book,
    OfferType.issue,
    OfferType.article,
  ];

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
      context.read<OffersListCubit>().loadMore();
    }
  }

  /// The urgent offer is the one entry here with a real offer id, so it's
  /// the one that can load `/public/offers/{id}`.
  Future<void> _openUrgentOffer(UrgentOfferModel urgent) async {
    Helpers.showLoadingDialog(context);
    try {
      final details = await OffersRemoteDataSourceImpl(ApiService())
          .getOfferDetails(urgent.id);
      if (!mounted) return;
      Helpers.hideLoadingDialog(context);
      openOfferScreen(details.toOffer(), content: details.toContent());
    } catch (e) {
      if (!mounted) return;
      Helpers.hideLoadingDialog(context);
      Helpers.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppStrings.tabAll.tr(),
      AppStrings.tabPackage.tr(),
      AppStrings.booksTab.tr(),
      AppStrings.tabIssuesOffer.tr(),
      AppStrings.articlesTab.tr(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.offersTitle.tr()),
      body: SafeArea(
        child: BlocBuilder<OffersListCubit, OffersListState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  child: OfferTypeTabs(
                    labels: labels,
                    selectedIndex: _types.indexOf(state.type),
                    onChanged: (i) =>
                        context.read<OffersListCubit>().changeType(_types[i]),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OffersListState state) {
    switch (state.status) {
      case OffersListStatus.initial:
      case OffersListStatus.loading:
        return const LoadingIndicator();

      case OffersListStatus.failure:
        return EmptyStateWidget(
          image: AppImages.noData,
          message: AppStrings.somethingWentWrong.tr(),
          message2: state.error ?? AppStrings.pleaseTryAgain.tr(),
          actionText: AppStrings.retry.tr(),
          onAction: () => context.read<OffersListCubit>().refresh(),
        );

      case OffersListStatus.empty:
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<OffersListCubit>().refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: EmptyStateWidget(
                  image: AppImages.noData,
                  message: AppStrings.noOffers.tr(),
                ),
              ),
            ],
          ),
        );

      case OffersListStatus.success:
      case OffersListStatus.loadingMore:
        final urgent = state.urgentOffer;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<OffersListCubit>().refresh(),
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              0,
              AppDimensions.paddingMedium,
              AppDimensions.paddingLarge,
            ),
            children: [
              if (urgent != null) ...[
                GestureDetector(
                  onTap: () => _openUrgentOffer(urgent),
                  child: OfferCountdownBanner(
                    // Keyed so a new urgent offer restarts the countdown.
                    key: ValueKey(urgent.id),
                    title: AppStrings.offerEndsInList.tr(),
                    endsAt: urgent.endsAt,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
              ],
              for (final offer in state.items) ...[
                OfferCard(offer: offer, onTap: () => openOfferScreen(offer)),
                const SizedBox(height: AppDimensions.paddingSmall),
              ],
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
    }
  }
}
