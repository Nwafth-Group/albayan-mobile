// ============================================
// FILE: lib/fatures/settings/screens/cubit/subscriptions_cubit.dart
// ============================================

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/shared_pref_helper.dart';
import '../../data/datasource/subscription_remote_data_source.dart';
import '../../data/models/subscription_model.dart';

part 'subscriptions_state.dart';

/// My Subscriptions — the current subscription plus the plans offered in
/// the Upgrade sheet, and the purchase call.
class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionRemoteDataSource dataSource;
  final String languageCode;

  SubscriptionsCubit(this.dataSource, {required this.languageCode})
    : super(const SubscriptionsState());

  bool _isFetching = false;

  Future<void> load() => _fetch();

  /// Pull-to-refresh: keeps the current content on screen while re-fetching.
  Future<void> refresh() => _fetch(silent: true);

  Future<void> _fetch({bool silent = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    if (!silent) {
      emit(state.copyWith(status: SubscriptionsStatus.loading, error: null));
    }

    // Plans are optional for this page (only the sheet needs them), so a
    // failure there doesn't fail the whole screen.
    final plansFuture = dataSource
        .getPlans(languageCode: languageCode)
        .then<List<SubscriptionPlanModel>?>((p) => p)
        .catchError((_) => null);

    try {
      final current = await dataSource.getCurrent(languageCode: languageCode);
      final plans = await plansFuture;
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SubscriptionsStatus.success,
          current: current,
          clearCurrent: current == null,
          plans: plans ?? state.plans,
        ),
      );
      _syncCachedUser(current);
    } catch (e) {
      final plans = await plansFuture;
      if (isClosed) return;
      emit(
        state.copyWith(
          status: state.status == SubscriptionsStatus.success
              ? SubscriptionsStatus.success
              : SubscriptionsStatus.failure,
          plans: plans ?? state.plans,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Retries just the plans (for the Upgrade sheet's error state).
  Future<void> loadPlans() async {
    try {
      final plans = await dataSource.getPlans(languageCode: languageCode);
      if (!isClosed) emit(state.copyWith(plans: plans));
    } catch (_) {}
  }

  /// Activates [plan]; returns true on success. API errors are already
  /// surfaced as a snackbar by `ApiService.post`.
  Future<bool> purchase(SubscriptionPlanModel plan) async {
    if (state.isPurchasing) return false;
    emit(state.copyWith(isPurchasing: true, error: null));
    try {
      // TODO(iap): pass the StoreKit / Play Billing transaction ids and
      // receipt once in-app purchases are integrated.
      await dataSource.purchase(
        planId: plan.id,
        platform: _platform,
        languageCode: languageCode,
      );
      if (isClosed) return true;
      emit(state.copyWith(isPurchasing: false));
      await refresh();
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isPurchasing: false, error: e.toString()));
      }
      return false;
    }
  }

  static String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }

  /// Keeps the cached profile's `have_subscription` flag (used by the home
  /// greeting badge) in step with what the API just returned.
  void _syncCachedUser(UserSubscriptionModel? current) {
    final user = SharedPrefHelper.getUser();
    if (user == null) return;
    final active = current?.isActive ?? false;
    if (user.haveSubscription == active) return;
    SharedPrefHelper.saveUser(
      user.copyWith(
        haveSubscription: active,
        subscriptionStatus: active ? 'Active' : null,
      ),
    );
  }
}
