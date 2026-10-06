// ============================================
// FILE: lib/fatures/issues/screens/cubit/archive_years_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/issues_remote_data_source.dart';
import '../../data/models/archive_year_model.dart';
import '../../data/models/pagination_meta.dart';

part 'archive_years_state.dart';

class ArchiveYearsCubit extends Cubit<ArchiveYearsState> {
  final IssuesRemoteDataSource dataSource;

  ArchiveYearsCubit(this.dataSource) : super(const ArchiveYearsState());

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
              ? ArchiveYearsStatus.loading
              : ArchiveYearsStatus.loadingMore,
          error: null,
        ),
      );
    }

    try {
      final result = await dataSource.getArchiveYears(page: page);
      if (isClosed) return;
      final merged = reset ? result.items : [...state.years, ...result.items];
      emit(
        state.copyWith(
          status: merged.isEmpty
              ? ArchiveYearsStatus.empty
              : ArchiveYearsStatus.success,
          years: merged,
          meta: result.meta,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: state.years.isEmpty
              ? ArchiveYearsStatus.failure
              : ArchiveYearsStatus.success,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }
}
