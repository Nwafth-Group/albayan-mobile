// ============================================
// FILE: lib/fatures/library/screens/cubit/library_summary_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/library_remote_data_source.dart';
import '../../data/models/library_summary_model.dart';

part 'library_summary_state.dart';

class LibrarySummaryCubit extends Cubit<LibrarySummaryState> {
  final LibraryRemoteDataSource dataSource;

  LibrarySummaryCubit(this.dataSource) : super(const LibrarySummaryState());

  Future<void> load() => _fetch();

  /// Pull-to-refresh: keeps the current counts on screen while re-fetching.
  Future<void> refresh() => _fetch(silent: true);

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: LibrarySummaryStatus.loading, error: null));
    }
    try {
      final summary = await dataSource.getSummary();
      emit(
        state.copyWith(status: LibrarySummaryStatus.success, summary: summary),
      );
    } catch (e) {
      // A failed pull-to-refresh keeps the counts already on screen.
      if (silent && state.status == LibrarySummaryStatus.success) return;
      emit(
        state.copyWith(
          status: LibrarySummaryStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
