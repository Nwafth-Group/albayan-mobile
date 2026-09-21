
// ============================================
// FILE: lib/fatures/search/screens/cubit/search_initial_state.dart
// ============================================

part of 'search_initial_cubit.dart';

enum SearchInitialStatus { initial, loading, success, failure }

class SearchInitialState extends Equatable {
  final SearchInitialStatus status;
  final SearchInitialModel data;
  final String? error;

  const SearchInitialState({
    this.status = SearchInitialStatus.initial,
    this.data = SearchInitialModel.empty,
    this.error,
  });

  bool get isLoading => status == SearchInitialStatus.loading;

  SearchInitialState copyWith({
    SearchInitialStatus? status,
    SearchInitialModel? data,
    String? error,
  }) {
    return SearchInitialState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
