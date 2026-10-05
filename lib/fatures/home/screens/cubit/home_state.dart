// ============================================
// FILE: lib/fatures/home/screens/cubit/home_state.dart
// ============================================

part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<HomeSectionModel> sections;
  final String? error;

  const HomeState({
    this.status = HomeStatus.initial,
    this.sections = const [],
    this.error,
  });

  bool get isLoading => status == HomeStatus.loading;

  HomeSectionModel? _byType(String type) {
    for (final s in sections) {
      if (s.meta.type == type) return s;
    }
    return null;
  }

  HomeSectionModel? _byKey(String key) {
    for (final s in sections) {
      if (s.meta.sectionKey == key) return s;
    }
    return null;
  }

  HomeSectionModel? get bannerSection => _byType('ad_banner');
  HomeSectionModel? get cornersSection => _byType('corners');
  HomeSectionModel? get issuesSection => _byType('issues');
  HomeSectionModel? get articlesSection => _byKey('articles');
  HomeSectionModel? get authorsSection => _byType('writers_authors');
  HomeSectionModel? get booksSection => _byType('books');
  HomeSectionModel? get freshNewsSection => _byKey('fresh_news');

  HomeState copyWith({
    HomeStatus? status,
    List<HomeSectionModel>? sections,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, sections, error];
}
