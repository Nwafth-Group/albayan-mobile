
// ============================================
// FILE: lib/fatures/language/cubit/language_cubit.dart
// ============================================

import 'package:albayan/fatures/onboarding/data/language_model.dart';
import 'package:albayan/fatures/onboarding/data/language_remote_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final LanguageRemoteDataSource _dataSource;

  LanguageCubit(this._dataSource) : super(const LanguageInitial());

  Future<void> fetchLanguages({String search = ''}) async {
    emit(const LanguageLoading());
    try {
      final languages = await _dataSource.getLanguages(search: search);

      // Pre-select English by default
      final defaultLang = languages.firstWhere(
            (l) => l.code == 'en',
        orElse: () => languages.isNotEmpty ? languages.first : languages.first,
      );

      emit(LanguageLoaded(languages: languages, selected: defaultLang));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }

  void selectLanguage(LanguageModel language) {
    final current = state;
    if (current is LanguageLoaded) {
      emit(current.copyWith(selected: language));
    }
  }
}