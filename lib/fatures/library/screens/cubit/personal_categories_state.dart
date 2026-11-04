// ============================================
// FILE: lib/fatures/library/screens/cubit/personal_categories_state.dart
// ============================================

part of 'personal_categories_cubit.dart';

enum PersonalCategoriesStatus { initial, loading, success, empty, failure }

class PersonalCategoriesState extends Equatable {
  final PersonalCategoriesStatus status;
  final List<PersonalCategoryModel> categories;
  final String? error;

  const PersonalCategoriesState({
    this.status = PersonalCategoriesStatus.initial,
    this.categories = const [],
    this.error,
  });

  PersonalCategoriesState copyWith({
    PersonalCategoriesStatus? status,
    List<PersonalCategoryModel>? categories,
    String? error,
  }) {
    return PersonalCategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, categories, error];
}
