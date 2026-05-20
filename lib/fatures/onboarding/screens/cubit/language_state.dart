
// ============================================
// FILE: lib/fatures/language/cubit/language_state.dart
// ============================================

import 'package:albayan/fatures/onboarding/data/language_model.dart';
import 'package:equatable/equatable.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial();
}

class LanguageLoading extends LanguageState {
  const LanguageLoading();
}

class LanguageLoaded extends LanguageState {
  final List<LanguageModel> languages;
  final LanguageModel? selected;

  const LanguageLoaded({required this.languages, this.selected});

  @override
  List<Object?> get props => [languages, selected];

  LanguageLoaded copyWith({
    List<LanguageModel>? languages,
    LanguageModel? selected,
  }) =>
      LanguageLoaded(
        languages: languages ?? this.languages,
        selected:  selected  ?? this.selected,
      );
}

class LanguageError extends LanguageState {
  final String message;
  const LanguageError(this.message);

  @override
  List<Object?> get props => [message];
}