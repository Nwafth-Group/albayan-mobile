// ============================================
// FILE: lib/fatures/settings/screens/cubit/policy_state.dart
// ============================================

part of 'policy_cubit.dart';

enum PolicyStatus { initial, loading, success, empty, failure }

class PolicyState extends Equatable {
  final PolicyStatus status;
  final PolicyModel? policy;
  final String? error;

  const PolicyState({
    this.status = PolicyStatus.initial,
    this.policy,
    this.error,
  });

  PolicyState copyWith({
    PolicyStatus? status,
    PolicyModel? policy,
    String? error,
  }) {
    return PolicyState(
      status: status ?? this.status,
      policy: policy ?? this.policy,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, policy?.id, policy?.content, error];
}
