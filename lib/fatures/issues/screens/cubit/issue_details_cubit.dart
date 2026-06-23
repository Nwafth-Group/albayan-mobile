
// ============================================
// FILE: lib/fatures/issues/screens/cubit/issue_details_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/issues_remote_data_source.dart';
import '../../data/models/issue_detail_model.dart';

part 'issue_details_state.dart';

class IssueDetailsCubit extends Cubit<IssueDetailsState> {
  final IssuesRemoteDataSource dataSource;
  final String issueId;

  IssueDetailsCubit(this.dataSource, {required this.issueId})
      : super(const IssueDetailsState());

  Future<void> load() async {
    emit(state.copyWith(status: DetailsStatus.loading, error: null));
    try {
      final detail = await dataSource.getIssueDetails(issueId);
      emit(state.copyWith(status: DetailsStatus.success, detail: detail));
    } catch (e) {
      emit(state.copyWith(
        status: DetailsStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Local optimistic toggle. Wire to the favorite API when available.
  void toggleFavorite() {
    final detail = state.detail;
    if (detail == null) return;
    emit(state.copyWith(
      detail: detail.copyWith(isFavorite: !detail.isFavorite),
    ));
    // TODO: call favorite/unfavorite endpoint and revert on failure.
  }
}