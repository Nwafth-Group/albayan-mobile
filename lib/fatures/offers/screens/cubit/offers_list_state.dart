
// ============================================
// FILE: lib/fatures/offers/screens/cubit/offers_list_state.dart
// ============================================

part of 'offers_list_cubit.dart';

enum OffersListStatus { initial, loading, loadingMore, success, empty, failure }

class OffersListState extends Equatable {
  final OffersListStatus status;

  /// Selected tab — `null` is "all".
  final OfferType? type;
  final String search;
  final List<OfferModel> items;
  final UrgentOfferModel? urgentOffer;
  final PaginationMeta? meta;
  final String? error;

  const OffersListState({
    this.status = OffersListStatus.initial,
    this.type,
    this.search = '',
    this.items = const [],
    this.urgentOffer,
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoadingMore => status == OffersListStatus.loadingMore;

  /// [type] and [urgentOffer] are nullable, so they're passed as getters to
  /// tell "set to null" apart from "leave unchanged".
  OffersListState copyWith({
    OffersListStatus? status,
    OfferType? Function()? type,
    String? search,
    List<OfferModel>? items,
    UrgentOfferModel? Function()? urgentOffer,
    PaginationMeta? meta,
    String? error,
  }) {
    return OffersListState(
      status: status ?? this.status,
      type: type != null ? type() : this.type,
      search: search ?? this.search,
      items: items ?? this.items,
      urgentOffer: urgentOffer != null ? urgentOffer() : this.urgentOffer,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, type, search, items, urgentOffer, meta, error];
}
