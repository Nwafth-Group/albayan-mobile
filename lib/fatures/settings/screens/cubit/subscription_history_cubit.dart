// ============================================
// FILE: lib/fatures/settings/screens/cubit/subscription_history_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/subscription_remote_data_source.dart';
import '../../data/models/subscription_model.dart';

part 'subscription_history_state.dart';

/// Subscription History — `GET /reader/subscriptions/history`, paginated.
/// Plans are loaded alongside so each card can show its price / features.
class SubscriptionHistoryCubit extends Cubit<SubscriptionHistoryState> {
  final SubscriptionRemoteDataSource dataSource;
  final String languageCode;

  SubscriptionHistoryCubit(this.dataSource, {required this.languageCode})
    : super(const SubscriptionHistoryState());

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh: keeps the current list on screen while re-fetching.
  Future<void> refresh() => _fetch(page: 1, reset: true, silent: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    await _fetch(page: (state.meta?.currentPage ?? 1) + 1, reset: false);
  }

  Future<void> _fetch({
    required int page,
    required bool reset,
    bool silent = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!silent) {
      emit(
        state.copyWith(
          status: reset
              ? SubscriptionHistoryStatus.loading
              : SubscriptionHistoryStatus.loadingMore,
          error: null,
        ),
      );
    }

    final plansFuture = reset
        ? dataSource
              .getPlans(languageCode: languageCode)
              .then<List<SubscriptionPlanModel>?>((p) => p)
              .catchError((_) => null)
        : Future<List<SubscriptionPlanModel>?>.value(null);

    try {
      final result = await dataSource.getHistory(
        page: page,
        languageCode: languageCode,
      );
      final plans = await plansFuture;
      if (isClosed) return;
      final merged = reset ? result.items : [...state.items, ...result.items];
      emit(
        state.copyWith(
          status: merged.isEmpty
              ? SubscriptionHistoryStatus.empty
              : SubscriptionHistoryStatus.success,
          items: merged,
          plans: plans,
          meta: result.meta,
        ),
      );
    } catch (e) {
      await plansFuture;
      if (isClosed) return;
      emit(
        state.copyWith(
          status: state.items.isEmpty
              ? SubscriptionHistoryStatus.failure
              : SubscriptionHistoryStatus.success,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }
}
