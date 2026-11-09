// ============================================
// FILE: lib/fatures/settings/utils/invoice_download.dart
// ============================================
//
// "Download invoice": fetches `GET /reader/orders/{id}/invoice/pdf` into the
// app's documents folder, then opens it with the system viewer via
// open_filex (Quick Look on iOS — with Share / Save to Files — and the
// user's PDF app on Android).

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../data/datasource/settings_remote_data_source.dart';

/// Downloads the invoice PDF and opens it. Returns true when it opened.
Future<bool> _downloadAndOpenInvoice({
  required String orderId,
  required String invoiceNumber,
}) async {
  try {
    final file = await SettingsRemoteDataSourceImpl(ApiService())
        .downloadInvoicePdf(
          orderId: orderId,
          fileName: invoiceNumber.isNotEmpty ? invoiceNumber : orderId,
        );
    final result = await OpenFilex.open(
      file.path,
      type: 'application/pdf',
      uti: 'com.adobe.pdf',
    );
    if (result.type == ResultType.done) return true;
    debugPrint('Invoice open failed: ${result.type} ${result.message}');
    AppNavigator.showErrorSnackBar(
      result.type == ResultType.noAppToOpen
          ? AppStrings.noAppToOpenPdf.tr()
          : AppStrings.invoiceDownloadFailed.tr(),
    );
  } catch (e) {
    debugPrint('Invoice download failed: $e');
    AppNavigator.showErrorSnackBar(AppStrings.invoiceDownloadFailed.tr());
  }
  return false;
}

/// For stateless screens: blocks with a loading dialog while downloading.
Future<void> openInvoicePdf(
  BuildContext context, {
  required String orderId,
  String invoiceNumber = '',
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  Helpers.showLoadingDialog(context);
  try {
    await _downloadAndOpenInvoice(
      orderId: orderId,
      invoiceNumber: invoiceNumber,
    );
  } finally {
    navigator.pop();
  }
}
