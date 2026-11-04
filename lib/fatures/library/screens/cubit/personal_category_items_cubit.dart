// ============================================
// FILE: lib/fatures/library/screens/cubit/personal_category_items_cubit.dart
// ============================================

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/library_remote_data_source.dart';
import '../../data/models/personal_category_model.dart';
import '../../utils/library_events.dart';

part 'personal_category_items_state.dart';

/// Items of one [type] (book / issue / article) inside a personal category.
class PersonalCategoryItemsCubit extends Cubit<PersonalCategoryItemsState> {
  StreamSubscription<void>? _libraryChangesSub;

  @override
  Future<void> close() {
    _libraryChangesSub?.cancel();
    return super.close();
  }

  final LibraryRemoteDataSource dataSource;
  final String categoryId;
  final PersonalCategoryType type;

  PersonalCategoryItemsCubit(
    this.dataSource, {
    required this.categoryId,
    required this.type,
  }) : super(const PersonalCategoryItemsState()) {
    // Refresh whenever a free item is added to My Library elsewhere.
    _libraryChangesSub = LibraryEvents.changes.listen((_) => refresh());
  }

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh: re-fetches page 1 but keeps the current list on
  /// screen (no full-screen loader) until the new page arrives.
  Future<void> refresh() => _fetch(page: 1, reset: true, silent: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
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
              ? PersonalCategoryItemsStatus.loading
              : PersonalCategoryItemsStatus.loadingMore,
          error: null,
        ),
      );
    }

    try {
      final result = await dataSource.getPersonalCategoryItems(
        categoryId,
        type: type,
        page: page,
      );
      final merged = reset ? result.items : [...state.items, ...result.items];

      emit(
        state.copyWith(
          status: merged.isEmpty
              ? PersonalCategoryItemsStatus.empty
              : PersonalCategoryItemsStatus.success,
          items: merged,
          meta: result.meta,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: state.items.isEmpty
              ? PersonalCategoryItemsStatus.failure
              : PersonalCategoryItemsStatus.success,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Adds library items to this category (one toggle-item call each), then
  /// reloads the list and tells the Categories tab to refresh its counts.
  /// Returns false if any call failed; the ones before it stay added.
  Future<bool> addItems(List<String> ids) async {
    if (ids.isEmpty) return true;
    var ok = true;
    for (final id in ids) {
      try {
        await dataSource.toggleCategoryItem(categoryId, type: type, itemId: id);
      } catch (_) {
        ok = false;
        break;
      }
    }
    LibraryEvents.notifyChanged();
    return ok;
  }

  /// Removes one item from this category (optimistically). Returns false
  /// and restores the item on failure.
  Future<bool> removeItem(String id) async {
    final before = state.items;
    final remaining = before.where((i) => i.id != id).toList();
    emit(
      state.copyWith(
        status: remaining.isEmpty
            ? PersonalCategoryItemsStatus.empty
            : PersonalCategoryItemsStatus.success,
        items: remaining,
      ),
    );
    try {
      // The item is in the category, so toggling removes it.
      await dataSource.toggleCategoryItem(categoryId, type: type, itemId: id);
      LibraryEvents.notifyChanged();
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: before.isEmpty
              ? PersonalCategoryItemsStatus.empty
              : PersonalCategoryItemsStatus.success,
          items: before,
        ),
      );
      return false;
    }
  }
}
