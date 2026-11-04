// ============================================
// FILE: lib/fatures/library/screens/cubit/library_item_picker_state.dart
// ============================================

part of 'library_item_picker_cubit.dart';

enum LibraryItemPickerStatus {
  initial,
  loading,
  loadingMore,
  success,
  empty,
  failure,
}

class LibraryItemPickerState extends Equatable {
  final LibraryItemPickerStatus status;
  final List<PersonalCategoryItem> items;
  final Set<String> selectedIds;
  final PaginationMeta? meta;
  final String? error;

  const LibraryItemPickerState({
    this.status = LibraryItemPickerStatus.initial,
    this.items = const [],
    this.selectedIds = const {},
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoadingMore => status == LibraryItemPickerStatus.loadingMore;

  LibraryItemPickerState copyWith({
    LibraryItemPickerStatus? status,
    List<PersonalCategoryItem>? items,
    Set<String>? selectedIds,
    PaginationMeta? meta,
    String? error,
  }) {
    return LibraryItemPickerState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, selectedIds, meta, error];
}
