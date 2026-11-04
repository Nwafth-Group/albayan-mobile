// ============================================
// FILE: lib/fatures/library/screens/cubit/personal_category_items_state.dart
// ============================================

part of 'personal_category_items_cubit.dart';

enum PersonalCategoryItemsStatus {
  initial,
  loading,
  loadingMore,
  success,
  empty,
  failure,
}

class PersonalCategoryItemsState extends Equatable {
  final PersonalCategoryItemsStatus status;
  final List<PersonalCategoryItem> items;
  final PaginationMeta? meta;
  final String? error;

  const PersonalCategoryItemsState({
    this.status = PersonalCategoryItemsStatus.initial,
    this.items = const [],
    this.meta,
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoadingMore => status == PersonalCategoryItemsStatus.loadingMore;

  PersonalCategoryItemsState copyWith({
    PersonalCategoryItemsStatus? status,
    List<PersonalCategoryItem>? items,
    PaginationMeta? meta,
    String? error,
  }) {
    return PersonalCategoryItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      meta: meta ?? this.meta,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, meta, error];
}
