// ============================================
// FILE: lib/fatures/library/screens/cubit/personal_categories_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/library_remote_data_source.dart';
import '../../utils/library_events.dart';
import '../../data/models/personal_category_model.dart';

part 'personal_categories_state.dart';

class PersonalCategoriesCubit extends Cubit<PersonalCategoriesState> {
  StreamSubscription<void>? _libraryChangesSub;

  @override
  Future<void> close() {
    _libraryChangesSub?.cancel();
    return super.close();
  }

  final LibraryRemoteDataSource dataSource;
  final PersonalCategoryType? type;

  /// With a [type], loads that type's category list; without one, loads the
  /// per-type counts shown on the Categories tab.
  PersonalCategoriesCubit(this.dataSource, {this.type})
    : super(const PersonalCategoriesState()) {
    // Refresh whenever a free item is added to My Library elsewhere.
    _libraryChangesSub = LibraryEvents.changes.listen((_) => refresh());
  }

  Future<void> load() => _fetch();

  /// Pull-to-refresh: keeps the current data on screen while re-fetching.
  Future<void> refresh() => _fetch(silent: true);

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(status: PersonalCategoriesStatus.loading, error: null),
      );
    }
    try {
      if (type == null) {
        final counts = await dataSource.getPersonalCategoryCounts();
        emit(
          state.copyWith(
            status: PersonalCategoriesStatus.success,
            counts: counts,
          ),
        );
      } else {
        final items = await dataSource.getPersonalCategories(type!);
        emit(
          state.copyWith(
            status: items.isEmpty
                ? PersonalCategoriesStatus.empty
                : PersonalCategoriesStatus.success,
            categories: items,
          ),
        );
      }
    } catch (e) {
      // A failed pull-to-refresh keeps the data already on screen.
      if (silent && state.status == PersonalCategoriesStatus.success) return;
      emit(
        state.copyWith(
          status: PersonalCategoriesStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
