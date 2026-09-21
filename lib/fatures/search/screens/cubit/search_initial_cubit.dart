
// ============================================
// FILE: lib/fatures/search/screens/cubit/search_initial_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/search_remote_data_source.dart';
import '../../data/models/search_initial_model.dart';

part 'search_initial_state.dart';

class SearchInitialCubit extends Cubit<SearchInitialState> {
  final SearchRemoteDataSource dataSource;

  SearchInitialCubit(this.dataSource) : super(const SearchInitialState());

  /// First load shows the spinner; later reloads (pull-to-refresh, returning
  /// from results) keep the current content visible and swap it when the
  /// response lands. A failed reload never wipes content that is on screen.
  Future<void> load() async {
    final hasContent = state.status == SearchInitialStatus.success;
    if (!hasContent) {
      emit(state.copyWith(status: SearchInitialStatus.loading, error: null));
    }
    try {
      final data = await dataSource.getInitial();
      emit(state.copyWith(
        status: SearchInitialStatus.success,
        data: data,
        error: null,
      ));
    } catch (e) {
      if (!hasContent) {
        emit(state.copyWith(
          status: SearchInitialStatus.failure,
          error: e.toString(),
        ));
      }
    }
  }

  /// Local-only removal — no delete-recent-search endpoint is available yet.
  void removeRecentSearch(String id) {
    final updated =
        state.data.recentSearches.where((r) => r.id != id).toList();
    emit(state.copyWith(
      data: SearchInitialModel(
        recentSearches: updated,
        trendingKeywords: state.data.trendingKeywords,
        discoveryArticles: state.data.discoveryArticles,
      ),
    ));
  }
}
