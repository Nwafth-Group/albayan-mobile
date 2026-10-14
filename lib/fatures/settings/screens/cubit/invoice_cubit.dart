// ============================================
// FILE: lib/fatures/settings/screens/cubit/invoice_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/data/models/cart_model.dart';
import '../../../cart/data/models/checkout_order_model.dart';
import '../../data/datasource/settings_remote_data_source.dart';
import '../../data/models/order_model.dart';

enum InvoiceStatus { loading, success, failure }

class InvoiceState extends Equatable {
  final InvoiceStatus status;
  final OrderModel? order;
  final String? error;

  const InvoiceState({
    this.status = InvoiceStatus.loading,
    this.order,
    this.error,
  });

  InvoiceState copyWith({
    InvoiceStatus? status,
    OrderModel? order,
    String? error,
  }) => InvoiceState(
    status: status ?? this.status,
    order: order ?? this.order,
    error: error,
  );

  @override
  List<Object?> get props => [status, order, error];
}

/// Fetches `GET /reader/orders/{id}/invoice` so any screen can open the
/// shared [InvoiceScreen] with just an order id, instead of carrying around
/// an already-loaded [OrderModel]. The endpoint has no line items, so
/// `order.items` is always empty here.
class InvoiceCubit extends Cubit<InvoiceState> {
  final SettingsRemoteDataSource dataSource;
  final String orderId;
  final String languageCode;

  InvoiceCubit(
    this.dataSource, {
    required this.orderId,
    required this.languageCode,
  }) : super(const InvoiceState());

  Future<void> load() async {
    emit(state.copyWith(status: InvoiceStatus.loading));
    try {
      final invoice = await dataSource.getInvoice(orderId);
      final order = OrderModel.fromCheckout(
        CheckoutOrderModel(
          id: invoice.id.isNotEmpty ? invoice.id : orderId,
          orderNumber: invoice.invoiceNumber,
          summary: CartSummaryModel(
            subtotal: invoice.subtotal,
            couponDiscount: invoice.discountAmount,
            taxRate: invoice.vatPercentage,
            taxAmount: invoice.vatAmount,
            totalAmount: invoice.totalAmount,
            currency: invoice.currency,
          ),
          paymentStatus: invoice.status,
          paymentReference: invoice.paymentReference,
          createdAt: invoice.createdAt,
          invoice: invoice,
        ),
        languageCode: languageCode,
      );
      if (!isClosed) {
        emit(state.copyWith(status: InvoiceStatus.success, order: order));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(status: InvoiceStatus.failure, error: '$e'));
      }
    }
  }
}
