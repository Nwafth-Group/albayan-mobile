
// ============================================
// FILE: lib/fatures/books/data/models/books_filter.dart
// ============================================

import 'package:equatable/equatable.dart';

class BooksFilter extends Equatable {
  final String? search;
  final int perPage;

  const BooksFilter({this.search, this.perPage = 15});

  bool get hasSearch => search != null && search!.trim().isNotEmpty;

  BooksFilter setSearch(String? value) => BooksFilter(
        search: (value == null || value.trim().isEmpty) ? null : value.trim(),
        perPage: perPage,
      );

  /// Builds query params; `search` is always sent (may be empty) to match
  /// `GET /public/books?per_page=15&search=`.
  Map<String, dynamic> toQuery({required int page}) {
    return {
      'page': page,
      'per_page': perPage,
      'search': search?.trim() ?? '',
    };
  }

  @override
  List<Object?> get props => [search, perPage];
}
