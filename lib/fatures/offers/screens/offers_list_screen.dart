
// ============================================
// FILE: lib/fatures/offers/screens/offers_list_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/models/offer_model.dart';
import '../data/offers_mock_data.dart';
import 'content_offer_screen.dart';
import 'issue_offer_screen.dart';
import 'package_offer_screen.dart';
import 'widgets/offer_card.dart';
import 'widgets/offer_countdown_banner.dart';
import 'widgets/offer_type_tabs.dart';

class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  // TODO: replace with a real cubit + datasource once an offers endpoint
  // exists. For now the screen renders straight from mock data.
  late final List<OfferModel> _all = mockOffers();
  int _tabIndex = 0;

  static const _types = [
    null,
    OfferType.package,
    OfferType.book,
    OfferType.issue,
    OfferType.article,
  ];

  List<OfferModel> get _filtered {
    final type = _types[_tabIndex];
    if (type == null) return _all;
    return _all.where((o) => o.type == type).toList();
  }

  void _openOffer(OfferModel offer) {
    switch (offer.type) {
      case OfferType.package:
        AppNavigator.push(PackageOfferScreen(offer: offer));
        break;
      case OfferType.issue:
        AppNavigator.push(IssueOfferScreen(offer: offer));
        break;
      case OfferType.book:
      case OfferType.article:
        AppNavigator.push(ContentOfferScreen(offer: offer));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: OfferTypeTabs(
                labels: labels,
                selectedIndex: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Expanded(
              child: items.isEmpty
                  ? EmptyStateWidget(
                      image: AppImages.noData,
                      message: AppStrings.noOffers.tr(),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.paddingMedium,
                        0,
                        AppDimensions.paddingMedium,
                        AppDimensions.paddingLarge,
                      ),
                      children: [
                        OfferCountdownBanner(
                          title: AppStrings.offerEndsInList.tr(),
                          endsAt: _earliestEndsAt(items),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        for (final offer in items) ...[
                          OfferCard(
                            offer: offer,
                            onTap: () => _openOffer(offer),
                          ),
                          const SizedBox(height: AppDimensions.paddingSmall),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _earliestEndsAt(List<OfferModel> items) {
    return items.map((o) => o.endsAt).reduce(
          (a, b) => a.isBefore(b) ? a : b,
        );
  }
}
