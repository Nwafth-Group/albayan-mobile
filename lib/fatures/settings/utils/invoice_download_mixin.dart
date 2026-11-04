// ============================================
// FILE: lib/fatures/settings/utils/invoice_download_mixin.dart
// ============================================
//
// "Download invoice" for any screen with a download button: fetches
// `GET /reader/orders/{id}/invoice/pdf`, then hands the bytes to the system
// save dialog (Files on iOS, the document picker on Android) so the PDF
// ends up somewhere the user can find it, and confirms with a snackbar.

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../data/datasource/settings_remote_data_source.dart';

mixin InvoiceDownloadStateMixin<T extends StatefulWidget> on State<T> {
  final SettingsRemoteDataSource _invoiceDataSource =
      SettingsRemoteDataSourceImpl(ApiService());

  bool _downloadingInvoice = false;

  /// Spinner state for the download button.
  bool get isDownloadingInvoice => _downloadingInvoice;

  Future<void> downloadInvoice({
    required String orderId,
    String invoiceNumber = '',
  }) async {
    if (_downloadingInvoice) return;
    setState(() => _downloadingInvoice = true);
    try {
      final name = invoiceNumber.isNotEmpty ? invoiceNumber : orderId;
      final file = await _invoiceDataSource.downloadInvoicePdf(
        orderId: orderId,
        fileName: name,
      );
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: AppStrings.downloadInvoice.tr(),
        fileName: file.uri.pathSegments.last,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: await file.readAsBytes(),
      );
      // Null = the user dismissed the save dialog.
      if (savedPath != null) {
        AppNavigator.showSuccessSnackBar(AppStrings.invoiceSaved.tr());
      }
    } catch (_) {
      AppNavigator.showErrorSnackBar(AppStrings.invoiceDownloadFailed.tr());
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }
}
