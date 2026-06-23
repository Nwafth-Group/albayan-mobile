
// ============================================
// FILE: lib/fatures/issues/screens/cubit/issues_cubit.dart
// ============================================

import 'dart:async';

import 'package:albayan/widgets/issues_filter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/issues_remote_data_source.dart';
import '../../data/models/issue_model.dart';
import '../../data/models/pagination_meta.dart';

part 'issues_state.dart';


class IssuesCubit extends Cubit<IssuesState> {
  final IssuesRemoteDataSource dataSource;

  /// The filter the page started with — what "Reset" returns to.
  final IssuesFilter _initialFilter;

  IssuesCubit(this.dataSource, {IssuesFilter? initialFilter})
      : _initialFilter = initialFilter ?? const IssuesFilter(),
        super(IssuesState(filter: initialFilter ?? const IssuesFilter()));

  Timer? _searchDebounce;
  bool _isFetching = false;

  /// First load / reload with the current filter.
  Future<void> loadIssues() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh.
  Future<void> refresh() => _fetch(page: 1, reset: true);

  /// Loads the next page if available.
  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Applies a new filter (from the filter sheet) and reloads from page 1.
  Future<void> applyFilter(IssuesFilter filter) async {
    emit(state.copyWith(filter: filter));
    await _fetch(page: 1, reset: true);
  }

  /// Resets EVERYTHING back to the initial state (same as first open):
  /// clears the date range and the issue-number search.
  Future<void> resetFilter() async {
    _searchDebounce?.cancel();
    emit(state.copyWith(filter: _initialFilter));
    await _fetch(page: 1, reset: true);
  }

  /// Debounced search by issue number. Empty input clears it.
  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      final trimmed = query.trim();
      final number = trimmed.isEmpty ? null : int.tryParse(trimmed);
      final filter = state.filter.setIssueNumber(number);
      emit(state.copyWith(filter: filter));
      _fetch(page: 1, reset: true);
    });
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(state.copyWith(
      status: reset ? IssuesStatus.loading : IssuesStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getIssues(
        filter: state.filter,
        page: page,
      );

      final merged = reset ? result.items : [...state.issues, ...result.items];

      emit(state.copyWith(
        status: merged.isEmpty ? IssuesStatus.empty : IssuesStatus.success,
        issues: merged,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        status:
        state.issues.isEmpty ? IssuesStatus.failure : IssuesStatus.success,
        error: e.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
