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

  /// Loads the reader's personal categories shown on the Categories tab.
  PersonalCategoriesCubit(this.dataSource)
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
      final items = await dataSource.getPersonalCategories();
      emit(
        state.copyWith(
          status: items.isEmpty
              ? PersonalCategoriesStatus.empty
              : PersonalCategoriesStatus.success,
          categories: items,
        ),
      );
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

  /// Creates a category and appends it. Returns false on failure (the
  /// ApiService has already surfaced the error message).
  Future<bool> create(String name) async {
    try {
      final created = await dataSource.createPersonalCategory(name);
      if (created.id.isEmpty) {
        await refresh();
      } else {
        emit(
          state.copyWith(
            status: PersonalCategoriesStatus.success,
            categories: [...state.categories, created],
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a category and drops it from the list. Returns false on failure.
  Future<bool> delete(String categoryId) async {
    try {
      await dataSource.deletePersonalCategory(categoryId);
      final remaining = state.categories
          .where((c) => c.id != categoryId)
          .toList();
      emit(
        state.copyWith(
          status: remaining.isEmpty
              ? PersonalCategoriesStatus.empty
              : PersonalCategoriesStatus.success,
          categories: remaining,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
