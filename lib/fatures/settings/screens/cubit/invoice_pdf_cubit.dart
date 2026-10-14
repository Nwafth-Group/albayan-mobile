// ============================================
// FILE: lib/fatures/settings/screens/cubit/invoice_pdf_cubit.dart
// ============================================

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/settings_remote_data_source.dart';

enum InvoicePdfStatus { loading, success, failure }

class InvoicePdfState extends Equatable {
  final InvoicePdfStatus status;
  final File? file;
  final String? error;

  const InvoicePdfState({
    this.status = InvoicePdfStatus.loading,
    this.file,
    this.error,
  });

  @override
  List<Object?> get props => [status, file?.path, error];
}

class InvoicePdfCubit extends Cubit<InvoicePdfState> {
  final SettingsRemoteDataSource dataSource;
  final String orderId;
  final String fileName;

  InvoicePdfCubit(
    this.dataSource, {
    required this.orderId,
    required this.fileName,
  }) : super(const InvoicePdfState());

  Future<void> download() async {
    emit(const InvoicePdfState());
    try {
      final file = await dataSource.downloadInvoicePdf(
        orderId: orderId,
        fileName: fileName,
      );
      if (!isClosed) {
        emit(InvoicePdfState(status: InvoicePdfStatus.success, file: file));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          InvoicePdfState(
            status: InvoicePdfStatus.failure,
            error: e.toString(),
          ),
        );
      }
    }
  }
}
