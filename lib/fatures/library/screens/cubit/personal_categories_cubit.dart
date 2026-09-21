// ============================================
// FILE: lib/fatures/library/screens/cubit/personal_categories_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/library_remote_data_source.dart';
import '../../data/models/personal_category_model.dart';

part 'personal_categories_state.dart';

class PersonalCategoriesCubit extends Cubit<PersonalCategoriesState> {
  final LibraryRemoteDataSource dataSource;
  final PersonalCategoryType? type;

  /// With a [type], loads that type's category list; without one, loads the
  /// per-type counts shown on the Categories tab.
  PersonalCategoriesCubit(this.dataSource, {this.type})
      : super(const PersonalCategoriesState());

  Future<void> load() async {
    emit(state.copyWith(status: PersonalCategoriesStatus.loading, error: null));
    try {
      if (type == null) {
        final counts = await dataSource.getPersonalCategoryCounts();
        emit(state.copyWith(
          status: PersonalCategoriesStatus.success,
          counts: counts,
        ));
      } else {
        final items = await dataSource.getPersonalCategories(type!);
        emit(state.copyWith(
          status: items.isEmpty
              ? PersonalCategoriesStatus.empty
              : PersonalCategoriesStatus.success,
          categories: items,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PersonalCategoriesStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
