
// ============================================
// FILE: lib/fatures/articles/data/models/articles_filter.dart
// ============================================

import 'package:equatable/equatable.dart';

class ArticlesFilter extends Equatable {
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int perPage;

  const ArticlesFilter({
    this.search,
    this.fromDate,
    this.toDate,
    this.perPage = 15,
  });

  bool get hasSearch => search != null && search!.trim().isNotEmpty;
  bool get hasDates => fromDate != null || toDate != null;

  ArticlesFilter setSearch(String? value) => ArticlesFilter(
        search: (value == null || value.trim().isEmpty) ? null : value.trim(),
        fromDate: fromDate,
        toDate: toDate,
        perPage: perPage,
      );

  ArticlesFilter setDates({DateTime? from, DateTime? to}) => ArticlesFilter(
        search: search,
        fromDate: from,
        toDate: to,
        perPage: perPage,
      );

  ArticlesFilter clearDates() => ArticlesFilter(
        search: search,
        fromDate: null,
        toDate: null,
        perPage: perPage,
      );

  /// Builds query params; null/empty values are omitted.
  Map<String, dynamic> toQuery({required int page}) {
    final map = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'search': search?.trim() ?? '',
    };
    if (fromDate != null) map['from_date'] = _fmt(fromDate!);
    if (toDate != null) map['to_date'] = _fmt(toDate!);
    return map;
  }

  static String _fmt(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  List<Object?> get props => [search, fromDate, toDate, perPage];
}
