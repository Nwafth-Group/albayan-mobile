
// ============================================
// FILE: lib/fatures/issues/screens/cubit/issue_details_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/data/favorites_sync.dart';
import '../../../favorites/data/models/favorite_item_model.dart';
import '../../data/datasource/issues_remote_data_source.dart';
import '../../data/models/issue_detail_model.dart';

part 'issue_details_state.dart';

class IssueDetailsCubit extends Cubit<IssueDetailsState> {
  final IssuesRemoteDataSource dataSource;
  final String issueId;

  late final StreamSubscription<FavoriteChange> _favoriteSub;

  IssueDetailsCubit(this.dataSource, {required this.issueId})
      : super(const IssueDetailsState()) {
    // Keep the heart in sync when this issue is (un)favorited elsewhere.
    _favoriteSub = FavoritesSync.changes.listen((c) {
      final detail = state.detail;
      if (detail != null && c.matches(FavoriteType.issue, detail.id)) {
        _setFavorite(c.isFavorite);
      }
    });
  }

  @override
  Future<void> close() {
    _favoriteSub.cancel();
    return super.close();
  }

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

  /// POST /reader/favorites/toggle — optimistic, settles on the server's
  /// answer (see [FavoritesSync.toggleOptimistic]).
  Future<void> toggleFavorite() async {
    final detail = state.detail;
    if (detail == null) return;
    await FavoritesSync.toggleOptimistic(
      type: FavoriteType.issue,
      id: detail.id,
      current: detail.isFavorite,
      apply: _setFavorite,
    );
  }

  void _setFavorite(bool isFavorite) {
    final detail = state.detail;
    if (isClosed || detail == null || detail.isFavorite == isFavorite) return;
    emit(state.copyWith(detail: detail.copyWith(isFavorite: isFavorite)));
  }
}
