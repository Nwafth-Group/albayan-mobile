// ============================================
// FILE: lib/fatures/cart/utils/cart_format.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';

import '../../../utils/constants.dart';

/// Formats a cart amount with the cart's `summary.currency` — the localized
/// SAR label for SAR (or when the API omits it), the raw code otherwise.
String cartMoney(num amount, [String? currency]) {
  final code = (currency == null || currency.isEmpty || currency == 'SAR')
      ? AppStrings.currencySar.tr()
      : currency;
  return '${amount.toStringAsFixed(2)} $code';
}
