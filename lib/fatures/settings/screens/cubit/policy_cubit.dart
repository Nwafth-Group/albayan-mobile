// ============================================
// FILE: lib/fatures/settings/screens/cubit/policy_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/settings_remote_data_source.dart';
import '../../data/models/policy_model.dart';

part 'policy_state.dart';

class PolicyCubit extends Cubit<PolicyState> {
  final SettingsRemoteDataSource dataSource;
  final PolicyType type;

  PolicyCubit(this.dataSource, this.type) : super(const PolicyState());

  Future<void> load() => _fetch();

  /// Pull-to-refresh: keeps the current policy on screen while re-fetching.
  Future<void> refresh() => _fetch(silent: true);

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: PolicyStatus.loading, error: null));
    }
    try {
      final policy = await dataSource.getPolicy(type);
      if (isClosed) return;
      final hasContent = policy != null && policy.content.trim().isNotEmpty;
      emit(
        state.copyWith(
          status: hasContent ? PolicyStatus.success : PolicyStatus.empty,
          policy: policy,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      // A failed pull-to-refresh keeps the policy already on screen.
      if (silent && state.status == PolicyStatus.success) return;
      emit(state.copyWith(status: PolicyStatus.failure, error: e.toString()));
    }
  }
}
