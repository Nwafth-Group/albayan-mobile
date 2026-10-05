
// ============================================
// FILE: lib/fatures/offers/screens/widgets/offer_format.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';

import '../../../../utils/constants.dart';
import '../../data/models/offer_model.dart';

/// `15` → "15", `11.25` → "11.25" — whole amounts drop the decimals, others
/// keep them so a real price is never rounded away.
String offerMoney(num value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(2);

/// "25%" for a percentage discount, "15 SAR" for a fixed one.
String offerDiscountLabel(OfferModel offer) {
  final value = offerMoney(offer.discountValue);
  return offer.discountType == OfferDiscountType.percentage
      ? '$value%'
      : '$value ${AppStrings.currencySar.tr()}';
}
