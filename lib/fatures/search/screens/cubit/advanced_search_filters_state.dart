
// ============================================
// FILE: lib/fatures/search/screens/cubit/advanced_search_filters_state.dart
// ============================================

part of 'advanced_search_filters_cubit.dart';

enum AdvancedSearchFiltersStatus { initial, loading, success, failure }

class AdvancedSearchFiltersState extends Equatable {
  final AdvancedSearchFiltersStatus status;
  final List<AuthorListModel> authors;
  final List<CategoryModel> categories;
  final List<CornerModel> corners;
  final List<KeywordModel> keywords;
  final List<LanguageModel> languages;
  final String? error;

  const AdvancedSearchFiltersState({
    this.status = AdvancedSearchFiltersStatus.initial,
    this.authors = const [],
    this.categories = const [],
    this.corners = const [],
    this.keywords = const [],
    this.languages = const [],
    this.error,
  });

  bool get isLoading => status == AdvancedSearchFiltersStatus.loading;

  AdvancedSearchFiltersState copyWith({
    AdvancedSearchFiltersStatus? status,
    List<AuthorListModel>? authors,
    List<CategoryModel>? categories,
    List<CornerModel>? corners,
    List<KeywordModel>? keywords,
    List<LanguageModel>? languages,
    String? error,
  }) {
    return AdvancedSearchFiltersState(
      status: status ?? this.status,
      authors: authors ?? this.authors,
      categories: categories ?? this.categories,
      corners: corners ?? this.corners,
      keywords: keywords ?? this.keywords,
      languages: languages ?? this.languages,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, authors, categories, corners, keywords, languages, error];
}
