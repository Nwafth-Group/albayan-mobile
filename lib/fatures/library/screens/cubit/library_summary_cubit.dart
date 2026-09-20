
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

  Future<void> load() async {
    emit(state.copyWith(status: LibrarySummaryStatus.loading, error: null));
    try {
      final summary = await dataSource.getSummary();
      emit(state.copyWith(
        status: LibrarySummaryStatus.success,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LibrarySummaryStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
