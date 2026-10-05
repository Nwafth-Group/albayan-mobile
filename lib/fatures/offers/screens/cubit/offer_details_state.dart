
// ============================================
// FILE: lib/fatures/offers/screens/cubit/offer_details_state.dart
// ============================================

part of 'offer_details_cubit.dart';

enum OfferDetailsStatus { initial, loading, success, failure }

class OfferDetailsState extends Equatable {
  final OfferDetailsStatus status;
  final OfferContent content;
  final String? error;

  const OfferDetailsState({
    this.status = OfferDetailsStatus.initial,
    this.content = const OfferContent(),
    this.error,
  });

  bool get isLoading =>
      status == OfferDetailsStatus.initial ||
      status == OfferDetailsStatus.loading;

  bool get isFailure => status == OfferDetailsStatus.failure;

  OfferDetailsState copyWith({
    OfferDetailsStatus? status,
    OfferContent? content,
    String? error,
  }) {
    return OfferDetailsState(
      status: status ?? this.status,
      content: content ?? this.content,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, content, error];
}
