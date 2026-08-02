
// ============================================
// FILE: lib/fatures/authors/screens/cubit/authors_list_state.dart
// ============================================

part of 'authors_list_cubit.dart';

enum AuthorsListStatus { initial, loading, loadingMore, success, empty, failure }

class AuthorsListState extends Equatable {
  final AuthorsListStatus status;
  final List<AuthorListModel> authors;
  final PaginationMeta? meta;
  final String query;
  final String? error;

  const AuthorsListState({
    this.status = AuthorsListStatus.initial,
    this.authors = const [],
    this.meta,
    this.query = '',
    this.error,
  });

  bool get hasMore => meta?.hasMore ?? false;
  bool get isLoading => status == AuthorsListStatus.loading;
  bool get isLoadingMore => status == AuthorsListStatus.loadingMore;

  AuthorsListState copyWith({
    AuthorsListStatus? status,
    List<AuthorListModel>? authors,
    PaginationMeta? meta,
    String? query,
    String? error,
  }) {
    return AuthorsListState(
      status: status ?? this.status,
      authors: authors ?? this.authors,
      meta: meta ?? this.meta,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, authors, meta, query, error];
}
