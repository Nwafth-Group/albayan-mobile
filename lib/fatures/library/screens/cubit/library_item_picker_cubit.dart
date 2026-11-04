// ============================================
// FILE: lib/fatures/library/screens/cubit/library_item_picker_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/library_remote_data_source.dart';
import '../../data/models/personal_category_model.dart';

part 'library_item_picker_state.dart';

/// Backs the "Choose from Your Library" sheet: pages through the reader's
/// owned books / issues / articles (by [type]) and tracks the selection.
class LibraryItemPickerCubit extends Cubit<LibraryItemPickerState> {
  final LibraryRemoteDataSource dataSource;
  final PersonalCategoryType type;

  LibraryItemPickerCubit(this.dataSource, {required this.type})
    : super(const LibraryItemPickerState());

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  void toggle(String id) {
    final selected = {...state.selectedIds};
    if (!selected.remove(id)) selected.add(id);
    emit(state.copyWith(selectedIds: selected));
  }

  Future<({List<PersonalCategoryItem> items, PaginationMeta meta})> _page(
    int page,
  ) async {
    switch (type) {
      case PersonalCategoryType.book:
        final r = await dataSource.getBooks(page: page);
        return (
          items: r.items.map(PersonalCategoryItem.book).toList(),
          meta: r.meta,
        );
      case PersonalCategoryType.issue:
        final r = await dataSource.getMagazineIssues(page: page);
        return (
          items: r.items.map(PersonalCategoryItem.issue).toList(),
          meta: r.meta,
        );
      case PersonalCategoryType.article:
        final r = await dataSource.getMagazineArticles(page: page);
        return (
          items: r.items.map(PersonalCategoryItem.article).toList(),
          meta: r.meta,
        );
    }
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    if (_isFetching) return;
    _isFetching = true;

    emit(
      state.copyWith(
        status: reset
            ? LibraryItemPickerStatus.loading
            : LibraryItemPickerStatus.loadingMore,
        error: null,
      ),
    );

    try {
      final result = await _page(page);
      final merged = reset ? result.items : [...state.items, ...result.items];
      emit(
        state.copyWith(
          status: merged.isEmpty
              ? LibraryItemPickerStatus.empty
              : LibraryItemPickerStatus.success,
          items: merged,
          meta: result.meta,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: state.items.isEmpty
              ? LibraryItemPickerStatus.failure
              : LibraryItemPickerStatus.success,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }
}
