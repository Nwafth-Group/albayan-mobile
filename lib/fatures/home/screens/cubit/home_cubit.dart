// ============================================
// FILE: lib/fatures/home/screens/cubit/home_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/home_remote_data_source.dart';
import '../../data/models/home_section_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRemoteDataSource dataSource;

  HomeCubit(this.dataSource) : super(const HomeState());

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

    // 1) Which sections the home page has, in the backend's order.
    List<HomeSectionRef> refs;
    try {
      refs = await dataSource.getSectionList();
    } catch (_) {
      refs = const [];
    }

    // 2) Every section's content in parallel; order is kept by Future.wait.
    final results = await Future.wait(refs.map((r) => _fetchOne(r.endpoint)));
    final sections = results
        .whereType<HomeSectionModel>()
        .where((s) => !s.isEmpty)
        .toList();

    if (sections.isEmpty) {
      // The list call or every section call failed — likely a real
      // connectivity/server issue rather than one bad section, so surface it.
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
