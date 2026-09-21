// ============================================
// FILE: lib/fatures/library/screens/cubit/personal_categories_state.dart
// ============================================

part of 'personal_categories_cubit.dart';

enum PersonalCategoriesStatus { initial, loading, success, empty, failure }

class PersonalCategoriesState extends Equatable {
  final PersonalCategoriesStatus status;
  final PersonalCategoryCounts counts;
  final List<PersonalCategoryModel> categories;
  final String? error;

  const PersonalCategoriesState({
    this.status = PersonalCategoriesStatus.initial,
    this.counts = PersonalCategoryCounts.empty,
    this.categories = const [],
    this.error,
  });

  PersonalCategoriesState copyWith({
    PersonalCategoriesStatus? status,
    PersonalCategoryCounts? counts,
    List<PersonalCategoryModel>? categories,
    String? error,
  }) {
    return PersonalCategoriesState(
      status: status ?? this.status,
      counts: counts ?? this.counts,
      categories: categories ?? this.categories,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, counts, categories, error];
}
