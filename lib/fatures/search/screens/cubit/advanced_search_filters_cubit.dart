
// ============================================
// FILE: lib/fatures/search/screens/cubit/advanced_search_filters_cubit.dart
// ============================================
//
// Loads the option lists shown on the Advanced Search screen: writers
// (`/public/authors`), categories (`/public/categories`), corners
// (`/public/corners`), languages (`/public/languages`) and keywords
// (`/public/keywords`). All five are paginated by the backend except
// languages, so each is walked page-by-page and flattened — the option
// lists are small enough that a single upfront load (no lazy paging in
// the picker sheets) keeps the UI simple.

import 'package:albayan/fatures/articles/data/models/keyword_model.dart';
import 'package:albayan/fatures/authors/data/datasource/authors_remote_data_source.dart';
import 'package:albayan/fatures/authors/data/models/author_list_model.dart';
import 'package:albayan/fatures/corners/data/datasource/corners_remote_data_source.dart';
import 'package:albayan/fatures/corners/data/models/corner_model.dart';
import 'package:albayan/fatures/onboarding/data/language_model.dart';
import 'package:albayan/fatures/onboarding/data/language_remote_datasource.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/search_filters_remote_data_source.dart';
import '../../data/models/category_model.dart';

part 'advanced_search_filters_state.dart';

class AdvancedSearchFiltersCubit extends Cubit<AdvancedSearchFiltersState> {
  final AuthorsRemoteDataSource authorsDataSource;
  final CornersRemoteDataSource cornersDataSource;
  final SearchFiltersRemoteDataSource filtersDataSource;
  final LanguageRemoteDataSource languagesDataSource;

  AdvancedSearchFiltersCubit({
    required this.authorsDataSource,
    required this.cornersDataSource,
    required this.filtersDataSource,
    required this.languagesDataSource,
  }) : super(const AdvancedSearchFiltersState());

  Future<void> load() async {
    emit(state.copyWith(
        status: AdvancedSearchFiltersStatus.loading, error: null));
    try {
      final results = await Future.wait([
        _fetchAllPages<AuthorListModel>((page) async {
          final r = await authorsDataSource.getAuthors(search: '', page: page);
          return (items: r.items, meta: r.meta);
        }),
        _fetchAllPages<CategoryModel>((page) async {
          final r = await filtersDataSource.getCategories(page: page);
          return (items: r.items, meta: r.meta);
        }),
        _fetchAllPages<CornerModel>((page) async {
          final r = await cornersDataSource.getCorners(search: '', page: page);
          return (items: r.items, meta: r.meta);
        }),
        _fetchAllPages<KeywordModel>((page) async {
          final r = await filtersDataSource.getKeywords(page: page);
          return (items: r.items, meta: r.meta);
        }),
      ]);
      final languages = await languagesDataSource.getLanguages();

      emit(state.copyWith(
        status: AdvancedSearchFiltersStatus.success,
        authors: results[0] as List<AuthorListModel>,
        categories: results[1] as List<CategoryModel>,
        corners: results[2] as List<CornerModel>,
        keywords: results[3] as List<KeywordModel>,
        languages: languages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdvancedSearchFiltersStatus.failure,
        error: e.toString(),
      ));
    }
  }

  /// Walks every page of a paginated list endpoint and flattens the items.
  Future<List<T>> _fetchAllPages<T>(
    Future<({List<T> items, PaginationMeta meta})> Function(int page)
        fetchPage,
  ) async {
    final all = <T>[];
    var page = 1;
    while (true) {
      final result = await fetchPage(page);
      all.addAll(result.items);
      if (!result.meta.hasMore || page > 20) break;
      page++;
    }
    return all;
  }
}
