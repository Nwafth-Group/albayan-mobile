
// ============================================
// FILE: lib/fatures/library/screens/cubit/library_issues_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/library_remote_data_source.dart';
import '../../data/models/library_issue_model.dart';

part 'library_issues_state.dart';

class LibraryIssuesCubit extends Cubit<LibraryIssuesState> {
  final LibraryRemoteDataSource dataSource;

  LibraryIssuesCubit(this.dataSource) : super(const LibraryIssuesState());

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  Future<void> refresh() => _fetch(page: 1, reset: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Local removal — no delete endpoint is available yet.
  void remove(String id) {
    final updated = state.issues.where((i) => i.id != id).toList();
    emit(state.copyWith(
      issues: updated,
      status:
          updated.isEmpty && state.status == LibraryIssuesStatus.success
              ? LibraryIssuesStatus.empty
              : state.status,
    ));
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(state.copyWith(
      status: reset
          ? LibraryIssuesStatus.loading
          : LibraryIssuesStatus.loadingMore,
      error: null,
    ));

    try {
      final result = await dataSource.getMagazineIssues(page: page);
      final merged =
          reset ? result.items : [...state.issues, ...result.items];

      emit(state.copyWith(
        status: merged.isEmpty
            ? LibraryIssuesStatus.empty
            : LibraryIssuesStatus.success,
        issues: merged,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.issues.isEmpty
            ? LibraryIssuesStatus.failure
            : LibraryIssuesStatus.success,
        error: e.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }
}
