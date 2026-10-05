// ============================================
// FILE: lib/fatures/home/screens/cubit/home_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/constants.dart';
import '../../data/datasource/home_remote_data_source.dart';
import '../../data/models/home_section_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRemoteDataSource dataSource;

  HomeCubit(this.dataSource) : super(const HomeState());

  /// The specific home-section content endpoints this home page renders —
  /// see the NOTE on `ApiConstants.homeSectionBanners` and siblings.
  static const _sectionEndpoints = [
    ApiConstants.homeSectionBanners,
    ApiConstants.homeSectionCorners,
    ApiConstants.homeSectionLatestIssues,
    ApiConstants.homeSectionArticles,
    ApiConstants.homeSectionWritersAuthors,
    ApiConstants.homeSectionBestBooks,
    ApiConstants.homeSectionFreshNews,
    ApiConstants.homeSectionCustom,
  ];

  /// First load — shows the full-screen loading state.
  Future<void> load() =>
      _fetchAll(showLoading: state.status == HomeStatus.initial);

  /// Pull-to-refresh — keeps whatever is already on screen while the new
  /// data comes in, instead of flashing the whole page back to a spinner.
  Future<void> refresh() => _fetchAll(showLoading: false);

  Future<HomeSectionModel?> _fetchOne(String endpoint) async {
    try {
      return await dataSource.getSection(endpoint);
    } catch (_) {
      // Swallowed per-section: one section failing (or 404ing) shouldn't
      // blank out every other section that loaded fine.
      return null;
    }
  }

  Future<void> _fetchAll({required bool showLoading}) async {
    if (showLoading) {
      emit(state.copyWith(status: HomeStatus.loading, error: null));
    }

    final results = await Future.wait(_sectionEndpoints.map(_fetchOne));
    final sections = results.whereType<HomeSectionModel>().toList();

    if (sections.isEmpty) {
      // Every single section call failed — likely a real connectivity/server
      // issue rather than one bad section, so surface it.
      emit(
        state.copyWith(
          status: state.sections.isEmpty
              ? HomeStatus.failure
              : HomeStatus.success,
          // No specific message — the screen shows a translated one.
          error: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomeStatus.success,
        sections: sections,
        error: null,
      ),
    );
  }
}
