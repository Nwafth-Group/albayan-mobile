// ============================================
// FILE: lib/fatures/settings/screens/invoice_pdf_screen.dart
// ============================================
//
// "Download Invoice": fetches `GET /reader/orders/{id}/invoice/pdf`, saves
// it on the device, shows it, and offers Share (Save to Files / send).

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/settings_remote_data_source.dart';
import 'cubit/invoice_pdf_cubit.dart';
import 'widgets/settings_widgets.dart';

class InvoicePdfScreen extends StatelessWidget {
  final String orderId;

  /// Used for the title and the saved file name (falls back to the order id).
  final String invoiceNumber;

  const InvoicePdfScreen({
    super.key,
    required this.orderId,
    this.invoiceNumber = '',
  });

  @override
  Widget build(BuildContext context) {
    final name = invoiceNumber.isNotEmpty ? invoiceNumber : orderId;
    return BlocProvider(
      create: (_) => InvoicePdfCubit(
        SettingsRemoteDataSourceImpl(ApiService()),
        orderId: orderId,
        fileName: name,
      )..download(),
      child: _InvoicePdfView(title: name),
    );
  }
}

class _InvoicePdfView extends StatelessWidget {
  final String title;
  const _InvoicePdfView({required this.title});

  Future<void> _share(BuildContext context, InvoicePdfState state) async {
    final file = state.file;
    if (file == null) return;
    // iPad needs an anchor rect for the share popover.
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: title,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoicePdfCubit, InvoicePdfState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: SettingsAppBar(
            title: title,
            actions: [
              if (state.status == InvoicePdfStatus.success)
                Builder(
                  builder: (buttonContext) => IconButton(
                    onPressed: () => _share(buttonContext, state),
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedShare08,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          body: switch (state.status) {
            InvoicePdfStatus.loading => const LoadingIndicator(),
            InvoicePdfStatus.failure => EmptyState(
              icon: Icons.error_outline,
              title: AppStrings.somethingWentWrong.tr(),
              subtitle: state.error ?? AppStrings.pleaseTryAgain.tr(),
              action: CustomButton(
                text: AppStrings.retry.tr(),
                onPressed: context.read<InvoicePdfCubit>().download,
              ),
            ),
            InvoicePdfStatus.success => SfPdfViewer.file(state.file!),
          },
        );
      },
    );
  }
}
